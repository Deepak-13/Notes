import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/Provider/comman.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class ReminderList extends ConsumerStatefulWidget{
    const ReminderList({super.key});

    @override
    ConsumerState<ReminderList> createState() => _ReminderListState();

}
class _ReminderListState extends ConsumerState<ReminderList>{
  final notify = NotificationService();
  Future<List<PendingNotificationRequest>> get list => notify.getAllNotification();

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Reminders"),
        ),
        body: Center(
        child: FutureBuilder<List<PendingNotificationRequest>>(
        future: list,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return const Center(child: Text("No reminders found"));
            }
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final item=ref.read(noteprovider.notifier).fetch(notification.id);
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          data("id", notification.id.toString()),
                          if (item!['ReminderDateTime'] !=null)data("DateTime",item['ReminderDateTime'].toLocal())
                        ],
                      ),
                    ),
                  ),
                );
              }
            );
          }
        },
      )
        )
      );
  }

  Widget data(label,value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: Text(label,style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16))),
        Expanded(child: Text(":",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16))),
        Expanded(child: Text(value,style:TextStyle(fontSize: 16)))
      ]
    );
  }
}