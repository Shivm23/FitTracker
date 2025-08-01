import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.0.0";

console.log("Delete user account");

serve(async (req) => {
  try {
    //Create instance of SupabaseClient
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    // Get the authorization header from the request.
    // When you invoke the function via the client library
    // it will automatically pass the authenticated user's JWT.
    const authHeader = req.headers.get("Authorization");

    // Get JWT from auth header
    const jwt = authHeader.replace("Bearer ", "");

    // Get the user object
    const {
      data: { user },
    } = await supabaseClient.auth.getUser(jwt);

    if (!user) throw new Error("No user found for JWT!");

    const userId = user.id;

    try {
      const { data: files, error: listError } = await supabaseClient
        .storage
        .from("exports")
        .list(userId, { limit: 100, offset: 0 });

      if (listError) {
        console.warn("⚠️ Failed to list files (non-blocking):", listError.message);
      } else if (files && files.length > 0) {
        console.log(`📂 Found ${files.length} file(s):`);
        files.forEach(file => console.log(` - ${userId}/${file.name}`));

        const pathsToDelete = files.map(file => `${userId}/${file.name}`);

        const { error: removeError } = await supabaseClient
          .storage
          .from("exports")
          .remove(pathsToDelete);

        if (removeError) {
          console.warn("⚠️ Failed to delete some files (non-blocking):", removeError.message);
        } else {
          console.log("✅ Files deleted successfully.");
        }
      } else {
        console.log("📭 No files found in user's folder.");
      }
    } catch (storageCatchError) {
      console.warn("⚠️ Storage deletion failed (non-blocking):", storageCatchError.message);
    }

  //Call deleteUser method and pass user's ID
  const { data, error } = await supabaseClient.auth.admin.deleteUser(user.id);
  if (error) {
    throw error;
  }

    return new Response(JSON.stringify(data), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify(error), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    });
  }
});
