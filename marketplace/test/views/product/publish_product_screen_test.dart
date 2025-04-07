import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace/views/product/product_publish.dart';
import 'package:marketplace/views/product/publish_product_screen.dart';

void main() {
  testWidgets(
    'PublishProductScreen renderiza los campos del formulario correctamente',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: PublishProductScreen()));

      expect(find.text('Título'), findsOneWidget);
      expect(find.text('Descripción'), findsOneWidget);
      expect(find.text('Precio'), findsOneWidget);
      expect(find.text('Categoría'), findsOneWidget);
      expect(find.text('Publicar Producto'), findsAtLeastNWidgets(1));
      expect(find.text('Seleccionar imágenes'), findsOneWidget);
    },
  );

  testWidgets('Al enviar formulario vacío muestra validaciones', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: PublishProductScreen()));

    await tester.tap(find.byKey(Key('submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Por favor ingresa un título'), findsOneWidget);
    expect(find.text('Por favor ingresa una descripción'), findsOneWidget);
    expect(find.text('Por favor ingresa un precio'), findsOneWidget);
  });
}
