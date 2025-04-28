import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutterinventory/data/models/sale_item.dart';
import 'package:flutterinventory/data/models/sale_detail_extended.dart';

class PdfGeneratorService {
  static Future<Uint8List> generateReceipt({
    required SaleItem sale,
    required List<SaleDetailExtended> products,
    required String branchName,
    required String branchLocation,
  }) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        pageFormat: PdfPageFormat.roll80,
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // HEADER
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        branchName,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        branchLocation,
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 10),
                    ],
                  ),
                ),
                pw.Divider(),

                // Info Venta
                pw.Text('#Venta: ${sale.saleNumber}'),
                pw.Text('Cliente: ${sale.clientName}'),
                pw.Text('Método de Pago: ${sale.paymentMethodName}'),
                pw.Text('Fecha: ${sale.date.toString().substring(0, 19)}'),
                pw.SizedBox(height: 10),

                pw.Divider(),

                // Productos
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      products.map((product) {
                        final subtotal = product.price * product.quantity;
                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  '${product.quantity} x ${product.productName}',
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                                pw.Text(
                                  '\$${subtotal.toStringAsFixed(2)}',
                                  style: pw.TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                          ],
                        );
                      }).toList(),
                ),

                pw.Divider(),

                // TOTAL
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '\$${sale.total.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    '¡Gracias por su compra!',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ),
                pw.SizedBox(height: 5),
              ],
            ),
      ),
    );

    return pdf.save();
  }
}
