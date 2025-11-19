import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/message_controller.dart';
import 'package:flutter_application_1/views/stage_content_view.dart';
// import 'package:flutter_application_1/models/listing_model.dart'; // Gerekmiyor

//
// DÜZELTME (Adım 70.4): 'StatefulWidget'tan 'StatelessWidget'a geri döndü
//
class MessageScreen extends StatelessWidget {
  // 'listing' parametresi ve 'initState' kaldırıldı.
  MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //
        // DÜZELTME: Başlığı 'Consumer' içinden alıyoruz
        //
        title: Consumer<MessageController>(
          builder: (context, controller, child) {
            return Text(
              'Satıcıya Mesaj: ${controller.listing.title}',
              style: const TextStyle(fontSize: 16),
            );
          },
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: Consumer<MessageController>(
        builder: (context, controller, child) {
          if (controller.conversation == null && controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Expanded(
                child: StageContentView(currentStep: controller.currentStep),
              ),
            ],
          );
        },
      ),
    );
  }
}
