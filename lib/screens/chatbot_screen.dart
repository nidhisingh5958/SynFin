import 'package:flutter/material.dart';
import '../services/agent_master.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage(this.text, {this.isUser = false});
}

class ChatbotScreen extends StatefulWidget {
  final String? initialMessage;
  final Map<String, dynamic>? initialContext;

  const ChatbotScreen({
    super.key,
    this.initialMessage,
    this.initialContext,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final _controller = TextEditingController();
  final _master = MasterAgent();
  bool _isProcessing = false;

  void _addMessage(String text, {bool isUser = false}) {
    setState(() {
      _messages.add(ChatMessage(text, isUser: isUser));
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _addMessage(text, isUser: true);

    setState(() => _isProcessing = true);

    // Start the conversation. For simplicity, we pass the user message only.
    final updates = <String>[];

    void onUpdate(String msg) {
      updates.add(msg);
      // add a short delay between updates for UX
      Future.microtask(() {
        _addMessage(msg, isUser: false);
      });
    }

  final result = await _master.startConversation(text, onUpdate);

    if (result['status'] == 'approved') {
      _addMessage('MasterAgent: Loan approved for INR ${result['approvedAmount'].toStringAsFixed(2)}', isUser: false);
      _addMessage('Sanction Letter:\n${result['sanctionLetter']}', isUser: false);
    } else if (result['status'] == 'needs_salary_slip') {
      _addMessage('MasterAgent: Please upload salary slip to continue.', isUser: false);
    } else if (result['status'] == 'rejected') {
      _addMessage('MasterAgent: Application rejected. Reason: ${result['reason']}', isUser: false);
    } else if (result['status'] == 'need_more_info') {
      _addMessage('MasterAgent: I need a bit more information to proceed.', isUser: false);
    }

    setState(() => _isProcessing = false);
  }

  @override
  void initState() {
    super.initState();
    // If initial message/context are provided, start immediately
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialMessage!;
        // start conversation with context
        _startWithInitial();
      });
    }
  }

  Future<void> _startWithInitial() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _addMessage(text, isUser: true);
    setState(() => _isProcessing = true);

    void onUpdate(String msg) {
      Future.microtask(() => _addMessage(msg, isUser: false));
    }

    final result = await _master.startConversation(text, onUpdate, context: widget.initialContext);

    if (result['status'] == 'approved') {
      _addMessage('MasterAgent: Loan approved for INR ${result['approvedAmount'].toStringAsFixed(2)}', isUser: false);
      _addMessage('Sanction Letter:\n${result['sanctionLetter']}', isUser: false);
    } else if (result['status'] == 'needs_salary_slip') {
      _addMessage('MasterAgent: Please upload salary slip to continue.', isUser: false);
    } else if (result['status'] == 'rejected') {
      _addMessage('MasterAgent: Application rejected. Reason: ${result['reason']}', isUser: false);
    } else if (result['status'] == 'need_more_info') {
      _addMessage('MasterAgent: I need a bit more information to proceed.', isUser: false);
    }

    setState(() => _isProcessing = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SynFin Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: m.isUser ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: m.isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(),
            ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Say something to the sales assistant...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: FloatingActionButton(
                    onPressed: _isProcessing ? null : _sendMessage,
                    child: const Icon(Icons.send),
                    mini: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
