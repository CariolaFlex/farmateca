// lib/test_json_parse.dart
// TEST TEMPORAL - Verificar parseo correcto del JSON

import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/compound_model.dart';
import 'models/brand_model.dart';

Future<void> testJsonParse() async {
  try {
    // Cargar JSON
    final String jsonString = await rootBundle.loadString(
      'assets/data/farmateca_master.json',
    );
    final Map<String, dynamic> data = json.decode(jsonString);

    // Verificar estructura raíz
    final compuestos = data['compuestos'] as List;
    final marcas = data['marcas'] as List;

    print(
      '✅ JSON cargado: ${compuestos.length} compuestos, ${marcas.length} marcas',
    );

    // Parsear primer compuesto
    final primerCompuestoJson = compuestos[0];
    final primerCompuesto = Compound.fromJson(primerCompuestoJson);

    print('\n🔍 PRIMER COMPUESTO:');
    print('  ID_PA: ${primerCompuesto.idPA}');
    print('  PA: ${primerCompuesto.pa}');
    print('  Familia: ${primerCompuesto.familia}');
    print('  Acceso: ${primerCompuesto.acceso}');
    print('  Marcas (string): ${primerCompuesto.marcas.substring(0, 50)}...');
    print(
      '  Marcas (lista): ${primerCompuesto.marcasList.length} marcas parseadas',
    );
    print('  ¿Es gratuito?: ${primerCompuesto.isGratuito}');

    // Parsear primera marca
    final primeraMarcaJson = marcas[0];
    final primeraMarca = Brand.fromJson(primeraMarcaJson);

    print('\n🔍 PRIMERA MARCA:');
    print('  ID_MA: ${primeraMarca.idMA}');
    print('  MA: ${primeraMarca.ma}');
    print('  PA_M: ${primeraMarca.paM}');
    print('  ID_PAM: ${primeraMarca.idPAM}');
    print('  Lab_M: ${primeraMarca.labM}');
    print('  Via_M: ${primeraMarca.viaM}');
    print('  Acceso_M: ${primeraMarca.accesoM}');
    print('  ¿Es marca comercial?: ${primeraMarca.esMarcaComercial}');

    // Verificar relación
    print('\n🔗 RELACIÓN:');
    print(
      '  primeraMarca.idPAM == primerCompuesto.idPA: ${primeraMarca.idPAM == primerCompuesto.idPA}',
    );

    print('\n✅ TEST EXITOSO - Modelos parseando correctamente');
  } catch (e, stack) {
    print('❌ ERROR: $e');
    print('Stack: $stack');
  }
}
