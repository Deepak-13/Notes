import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class Datetimesheet extends ConsumerStatefulWidget{

   const Datetimesheet({
    super.key,
    required this.setreminder,
    required this.reminder,
    this.reminderDateTime,
    this.frequency = "Once",
  });
  final Function setreminder;
  final int reminder;
  final tz.TZDateTime? reminderDateTime;
  final String frequency;

  @override
  ConsumerState<Datetimesheet> createState() => _Datetimesheet();
}


class _Datetimesheet extends ConsumerState<Datetimesheet>{
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedFrequency = "Once";


  @override
  void initState() {
    super.initState();
    selectedFrequency = widget.frequency;
    if(widget.reminder==1 && widget.reminderDateTime!=null)
    { 
      selectedDate = widget.reminderDateTime!.toLocal();
      selectedTime = TimeOfDay.fromDateTime(widget.reminderDateTime!);
    }
  }
 Future<void> _selectDate() async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(selectedDate.year,selectedDate.month,selectedDate.day),
    lastDate: DateTime(selectedDate.year + 100),
  );

  if (pickedDate == null) return;

  setState(() {
    selectedDate = pickedDate;
  });
  print("Date .....$selectedDate,$pickedDate");
}

Future<void> _selectTime() async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: selectedTime,
  );

  if (pickedTime == null) return;

  setState(() {
    selectedTime = pickedTime;
  });
   print("Time .....$selectedTime,$pickedTime");
}

void _selectFrequency() async {
    final String? pickedFrequency = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0), // Adjust position as needed or use a different picker
      items: <String>['Once', 'Daily', 'Weekly', 'Monthly', 'Yearly']
          .map((String value) {
        return PopupMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

    if (pickedFrequency != null) {
      setState(() {
        selectedFrequency = pickedFrequency;
      });
    }
  }

  // Alternative using a bottom sheet or simple dialog if showMenu is tricky with position
  Future<void> _showFrequencyPicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <String>['Once', 'Daily', 'Weekly', 'Monthly', 'Yearly'].map((String value) {
              return ListTile(
                title: Text(value),
                onTap: () {
                  setState(() {
                    selectedFrequency = value;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }


ButtonStyle commonBtnStyle(){
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }


ButtonStyle primaryBtnStyle(BuildContext context){
  return TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );
} 

Expanded btn(BuildContext context,value,label){
    return  Expanded(
      child: TextButton(
      style: value!=1?commonBtnStyle():primaryBtnStyle(context),
      onPressed: () {
          final tzTime = tz.TZDateTime(
            tz.local,
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
            0,0,0
          );
          print("combined time... ${selectedTime.hour}...${selectedTime.minute}...$tzTime...");
        widget.setreminder(value,tzTime, selectedFrequency);
        Navigator.pop(context);
        }, 
      child: Text("$label")
      ),
    ); 
}


Widget _dateTimeTile({
  required BuildContext context,
  required IconData icon,
  required String label,
  required String value,
  required VoidCallback onTap,
}) {
  return 
  Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(40),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      )));
}

  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height: 380, // Increased height to accommodate new field
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                      "Set Reminder",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                ),
              const SizedBox(height: 14),
              Expanded(child: 
                _dateTimeTile(
                  context: context,
                  icon: Icons.calendar_month_rounded,
                  label: "Date",
                  value: DateFormat("dd MMMM").format(selectedDate),
                  onTap: _selectDate,
                )
              ),
              const SizedBox(height: 12),
              Expanded(child: 
              _dateTimeTile(
                context: context,
                icon: Icons.access_time_rounded,
                label: "Time",
                value: selectedTime.format(context),
                onTap: _selectTime,
              )),
               const SizedBox(height: 12),
              Expanded(child: 
              _dateTimeTile(
                context: context,
                icon: Icons.repeat_rounded,
                label: "Frequency",
                value: selectedFrequency,
                onTap: _showFrequencyPicker,
              )),
              const Spacer(),
              Row(
                children: [
                  if (widget.reminder == 1)
                    btn(context, 0, "Delete"),
                  if (widget.reminder == 1) const SizedBox(width: 10),
                  btn(context, 2, "Cancel"),
                  const SizedBox(width: 10),
                  btn(context, 1, "Save"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
