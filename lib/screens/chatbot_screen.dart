import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {

  List<String> messages = [];

  TextEditingController controller =
      TextEditingController();

  void sendMessage(){

    if(controller.text.isEmpty) return;

    setState(() {

      messages.add("You: ${controller.text}");

      messages.add("Bot: Help request received");

    });

    controller.clear();

  }

  Widget helpButton(String text){

    return Padding(

      padding: const EdgeInsets.all(5),

      child: ElevatedButton(

        onPressed: (){

          setState(() {

            messages.add("Help: $text");

            messages.add("Bot: Opening $text");

          });

        },

        child: Text(text),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Help Chatbot"),
      ),

      body: Column(

        children: [

          /// Help Menu (25 features)

          Expanded(

            child: ListView(

              children: [

                helpButton("Track Bus"),
                helpButton("ETA Time"),
                helpButton("Nearby Bus"),
                helpButton("Routes"),
                helpButton("Schedule"),
                helpButton("Book Ticket"),
                helpButton("My Tickets"),
                helpButton("Ticket Price"),
                helpButton("Seat Availability"),
                helpButton("Travel History"),
                helpButton("Complaint"),
                helpButton("Lost Item"),
                helpButton("SOS Help"),
                helpButton("Call Police"),
                helpButton("Call Ambulance"),
                helpButton("Share Location"),
                helpButton("Safety Tips"),
                helpButton("Login Problem"),
                helpButton("Reset Password"),
                helpButton("Update Profile"),
                helpButton("Contact Support"),
                helpButton("Driver Details"),
                helpButton("Bus Delay"),
                helpButton("Bus Stops"),
                helpButton("Help Guide"),

              ],

            ),

          ),

          /// Chat Area

          Expanded(

            child: ListView.builder(

              itemCount: messages.length,

              itemBuilder:(c,i){

                return ListTile(

                  title: Text(messages[i]),

                );

              },

            ),

          ),

          Row(

            children: [

              Expanded(

                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      hintText: "Ask Help..."
                  ),
                ),

              ),

              IconButton(

                onPressed: sendMessage,

                icon: const Icon(Icons.send),

              )

            ],

          )

        ],

      ),

    );

  }

}