import { createClient } from 'npm:@supabase/supabase-js@2'
import { JWT } from 'npm:google-auth-library@9'
import serviceAccount from './service-account.json' with { type: 'json' }

interface CoachMacroGoal {
  user_id: string
  start_date: string
  calorie_goal: number
  carb_goal: number
  fat_goal: number
  protein_goal: number
}

interface WebhookPayload {
  type: 'INSERT' | 'UPDATE'
  table: 'coach_macro_goals'
  record: CoachMacroGoal
  schema: 'public'
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json()

  const { data: tokens, error } = await supabase
    .from('user_devices')
    .select('fcm_token')
    .eq('user_id', payload.record.user_id)

  if (error || !tokens || tokens.length === 0) {
    console.error('[❌] Aucun FCM token trouvé pour user:', payload.record.user_id)
    return new Response('No FCM token found', { status: 404 })
  }

  const accessToken = await getAccessToken({
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  })

  const notifBody = `Nouvel objectif : (${payload.record.carb_goal}, ${payload.record.fat_goal}, ${payload.record.protein_goal}) dès le ${payload.record.start_date}.`

  const responses = await Promise.all(
    tokens.map(({ fcm_token }) =>
      fetch(
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${accessToken}`,
          },
          body: JSON.stringify({
            message: {
              token: fcm_token,
              notification: {
                title: '📊 Nouveaux objectifs nutritionnels',
                body: notifBody,
              },
            },
          }),
        }
      )
    )
  )

  const errors = await Promise.all(responses.map(r => r.ok ? null : r.json()))
  const failed = errors.filter(Boolean)

  return new Response(
    JSON.stringify({
      success: tokens.length - failed.length,
      failed: failed.length,
    }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})

const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string
  privateKey: string
}): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err)
        return
      }
      resolve(tokens!.access_token!)
    })
  })
}
