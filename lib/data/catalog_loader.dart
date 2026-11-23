import 'package:flutter/services.dart';

import '../models/catalog.dart';

const catalogAssetPath = 'assets/data/catalogo.json';

Future<Catalog> loadCatalog([AssetBundle? bundle]) async {
  final source = await (bundle ?? rootBundle).loadString(catalogAssetPath);
  return Catalog.fromJsonString(source);
}
