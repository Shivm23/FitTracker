import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/usecase/get_config_usecase.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/usecase/search_products_usecase.dart';

part 'products_event.dart';

part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final log = Logger('ProductsBloc');

  final SearchProductsUseCase _searchProductUseCase;
  final GetConfigUsecase _getConfigUsecase;

  String _searchString = "";

  ProductsBloc(this._searchProductUseCase, this._getConfigUsecase)
      : super(ProductsInitial()) {
    on<LoadProductsEvent>((event, emit) async {
      if (event.searchString != _searchString) {
        _searchString = event.searchString;
        emit(ProductsLoadingState());
        try {
          final offResults = await _searchProductUseCase
              .searchOFFProductsByString(_searchString);
          final fdcResults = await _searchProductUseCase
              .searchFDCFoodByString(_searchString);
          final combined = _sortResults([...offResults, ...fdcResults]);
          final config = await _getConfigUsecase.getConfig();

          emit(ProductsLoadedState(
              products: combined, usesImperialUnits: config.usesImperialUnits));
        } catch (error) {
          log.severe(error);
          emit(ProductsFailedState());
        }
      }
    });
    on<RefreshProductsEvent>((event, emit) async {
      emit(ProductsLoadingState());
      try {
        final offResults = await _searchProductUseCase
            .searchOFFProductsByString(_searchString);
        final fdcResults = await _searchProductUseCase
            .searchFDCFoodByString(_searchString);
        final combined = _sortResults([...offResults, ...fdcResults]);
        emit(ProductsLoadedState(products: combined));
      } catch (error) {
        log.severe(error);
        emit(ProductsFailedState());
      }
    });
  }

  List<MealEntity> _sortResults(List<MealEntity> results) {
    int score(MealEntity meal) {
      final name = (meal.name ?? '').toLowerCase();
      final query = _searchString.toLowerCase();
      if (name == query) return 0;
      if (name.startsWith(query)) return 1;
      if (name.contains(query)) return 2;
      return 3;
    }

    results.sort((a, b) {
      final sa = score(a);
      final sb = score(b);
      if (sa != sb) return sa - sb;
      return (a.name ?? '').compareTo(b.name ?? '');
    });

    return results;
  }
}
