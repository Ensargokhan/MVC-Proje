import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // YENİ EKLENDİ (Sayı formatı için)
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/message_controller.dart';
import 'package:flutter_application_1/models/message_template_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StageContentView extends StatelessWidget {
  final int currentStep;

  const StageContentView({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MessageController>(context);

    switch (currentStep) {
      case 1:
        final priceTemplates = controller.priceTemplates;
        final selected = controller.selectedTemplate;
        final needsPrice =
            selected != null && selected.paramKeys.contains('price');
        if (priceTemplates.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Mesaj şablonları yüklenemedi. Lütfen daha sonra tekrar deneyin.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: controller.messages.isEmpty
                  ? const Center(child: Text('Henüz mesaj yok.'))
                  : ListView.builder(
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final msg = controller.messages[index];
                        final isMine = controller.isMessageMine(msg);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          alignment:
                              isMine ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMine ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(controller.renderMessage(msg)),
                          ),
                        );
                      },
                    ),
            ),
            if (controller.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  controller.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<MessageTemplate>(
                    value: selected,
                    hint: const Text('Mesaj Şablonu Seçin...'),
                    isExpanded: true,
                    items: priceTemplates.map((template) {
                      return DropdownMenuItem(
                        value: template,
                        child: Text(template.text, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: controller.onTemplateChanged,
                  ),
                  if (needsPrice)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Fiyat Teklifi (TL)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: controller.onPriceParameterChanged,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: controller.isLoading || selected == null
                              ? null
                              : () => controller.sendTemplateMessage(),
                          child: controller.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Gönder'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: controller.showAppointmentForm,
                        child: const Text('Randevu Planla'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

      // --- DİĞER CASE'LER DEĞİŞMEDİ ---
      case 2:
        // Randevu oluşturulmuşsa onay ekranını göster
        if (controller.appointment != null) {
          final appointment = controller.appointment!;
          final bothApproved = controller.bothApprovedAppointment;
          final hasApproved = controller.hasApprovedAppointment;
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '2. AŞAMA: Randevu Onayı',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tarih: ${appointment.date}'),
                          const SizedBox(height: 8),
                          Text('Saat: ${appointment.time}'),
                          const SizedBox(height: 8),
                          Text('Konum: ${appointment.location}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (bothApproved)
                    const Card(
                      color: Colors.green,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '✓ Her iki taraf da randevuyu onayladı!',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (hasApproved)
                    const Card(
                      color: Colors.orange,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '⏳ Karşı tarafın onayını bekliyorsunuz...',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Card(
                      color: Colors.blue[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Randevuyu onaylamak için butona tıklayın',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : controller.approveAppointment,
                              child: controller.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Randevuyu Onayla'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (!bothApproved)
                    TextButton(
                      onPressed: controller.backToMessages,
                      child: const Text('Mesajlara Dön'),
                    ),
                ],
              ),
            ),
          );
        }
        
        // Randevu henüz oluşturulmamışsa formu göster
        return SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '2. AŞAMA: Randevu Tarihi ve Saati Belirleyin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: controller.focusedDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(formatButtonVisible: false),
                selectedDayPredicate: (day) =>
                    isSameDay(controller.selectedDay, day),
                onDaySelected: controller.onDaySelected,
                enabledDayPredicate: (day) =>
                    day.isAfter(DateTime.now().subtract(const Duration(days: 1))),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButtonFormField<String>(
                  hint: const Text('Buluşma Saati Seçin (07:00-22:00)'),
                  value: controller.selectedTime,
                  items: controller.availableTimes
                      .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                      .toList(),
                  onChanged: controller.updateTime,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButtonFormField<String>(
                  hint: const Text('Buluşma Konumu Seçin (Kampüs İçi)'),
                  value: controller.selectedLocation,
                  items: controller.campusLocations
                      .map((location) => DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          ))
                      .toList(),
                  onChanged: controller.updateLocation,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isLoading ||
                                controller.selectedDay == null ||
                                controller.selectedTime == null ||
                                controller.selectedLocation == null
                            ? null
                            : controller.submitAppointment,
                        child: controller.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Randevuyu Oluştur'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: controller.backToMessages,
                      child: const Text('İptal'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 3:
        final appt = controller.appointment;
        String dateText = 'Tarih belirlenmedi';
        if (appt?.date != null) {
          final parsed = DateTime.tryParse(appt!.date);
          if (parsed != null) {
            dateText =
                '${parsed.day.toString().padLeft(2, '0')}.${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
          } else {
            dateText = appt.date;
          }
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Icon(Icons.handshake, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  '3. AŞAMA: Buluşma ve Teslim',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Randevu Özeti Kartı
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Buluşma Detayları',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            dateText,
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(appt?.time ?? 'Saat belirlenmedi'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(appt?.location ?? 'Konum belirlenmedi'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  'Ürünü teslim aldınız mı ve ödemeyi yaptınız mı?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // İki taraflı onay durumu
                Builder(
                  builder: (context) {
                    final bothApprovedDelivery = controller.bothApprovedDelivery;
                    final hasApprovedDelivery = controller.hasApprovedDelivery;
                    final isBuyer = controller.isBuyer;
                    
                    if (bothApprovedDelivery) {
                      return const Card(
                        color: Colors.green,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '✓ Her iki taraf da teslimatı onayladı!',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else if (hasApprovedDelivery) {
                      return const Card(
                        color: Colors.orange,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '⏳ Karşı tarafın onayını bekliyorsunuz...',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else if (isBuyer) {
                      // Sadece buyer (alıcı) teslim alabilir, seller (satıcı) alamaz
                      return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: controller.isLoading
                            ? null
                            : controller.approveDelivery,
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text(
                          'Evet, Teslim Aldım',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      );
                    } else {
                      // Seller (satıcı) için mesaj göster
                      return const Card(
                        color: Colors.blue,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Alıcının teslim onayını bekliyorsunuz...',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      case 4:
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              // ... (Aşama 4 kodu aynı)
              children: [
                const Text(
                  '4. AŞAMA: Geri Bildirim',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text('Lütfen satıcıyı puanlayın (1-5):'),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    controller.updateRating(rating);
                  },
                ),
                const SizedBox(height: 30),
                DropdownButtonFormField<String>(
                  hint: const Text('Şablon Yorum Seçin'),
                  items: const [
                    DropdownMenuItem(
                      value: 'iyi',
                      child: Text('Güvenilir satıcı, teşekkürler.'),
                    ),
                    DropdownMenuItem(
                      value: 'orta',
                      child: Text('İletişim iyiydi.'),
                    ),
                    DropdownMenuItem(
                      value: 'kotu',
                      child: Text('Buluşmaya geç geldi.'),
                    ),
                  ],
                  onChanged: (value) {
                    controller.updateFeedbackTemplate(value);
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed:
                      (controller.selectedRating == 0 ||
                              controller.selectedFeedbackTemplate == null)
                          ? null
                          : controller.submitFeedback,
                  child: const Text('Geri Bildirimi Tamamla'),
                ),
              ],
            ),
          ),
        );
      default:
        return const Text('Bilinmeyen Aşama');
    }
  }
}
