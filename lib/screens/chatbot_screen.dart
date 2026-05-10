import 'package:SynFin/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? agentName;

  ChatMessage(this.text, {this.isUser = false, this.agentName});
}

class ChatbotScreen extends StatefulWidget {
  final String customerId;
  final String? initialMessage;
  final Map<String, dynamic>? initialContext;

  const ChatbotScreen({
    super.key,
    required this.customerId,
    this.initialMessage,
    this.initialContext,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final _controller = TextEditingController();
  final _apiService = ChatApiService();
  final _scrollController = ScrollController();

  bool _isProcessing = false;
  String? _applicationId;
  String? _currentStatus;

  @override
  void initState() {
    super.initState();
    // If initial message/context are provided, start immediately
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialMessage!;
        _sendMessage();
      });
    }
  }

  void _addMessage(String text, {bool isUser = false, String? agentName}) {
    setState(() {
      _messages.add(ChatMessage(text, isUser: isUser, agentName: agentName));
    });

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isProcessing) return;

    _controller.clear();
    _addMessage(text, isUser: true);

    setState(() => _isProcessing = true);

    try {
      final response = await _apiService.sendMessage(
        customerId: widget.customerId,
        message: text,
        applicationId: _applicationId,
        dataUpdate: widget.initialContext,
      );

      // Update application ID if this is the first message
      if (_applicationId == null && response.applicationId != null) {
        _applicationId = response.applicationId;
      }

      // Update current status
      _currentStatus = response.status;

      // Add agent response
      if (response.message != null && response.message!.isNotEmpty) {
        _addMessage(
          response.message!,
          isUser: false,
          agentName: response.agentName,
        );
      }

      // Handle different statuses
      _handleStatus(response);
    } catch (e) {
      _addMessage('Error: ${e.toString()}', isUser: false, agentName: 'System');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _handleStatus(ChatResponse response) {
    switch (response.status) {
      case 'approved':
        _showSuccessDialog('Loan Approved!');
        break;
      case 'rejected':
        _showErrorDialog('Application Rejected');
        break;
      case 'needs_salary_slip':
        _showActionRequired('Please upload your salary slip');
        break;
      case 'need_more_info':
        // Agent will ask for more info in the message
        break;
    }

    // Handle action required
    if (response.actionRequired != null &&
        response.actionRequired!.isNotEmpty) {
      _showActionRequired(response.actionRequired!);
    }
  }

  void _showSuccessDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Your loan application has been approved!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text(
          'Unfortunately, your application was not approved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showActionRequired(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action Required: $action'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SynFin Chatbot'),
        actions: [
          if (_applicationId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'ID: ${_applicationId!.substring(0, 8)}...',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          if (_currentStatus != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _getStatusColor(_currentStatus!),
              child: Text(
                'Status: ${_currentStatus!.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Start a conversation...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      return Align(
                        alignment: m.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: m.isUser
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (m.agentName != null && !m.isUser)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    m.agentName!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              Text(
                                m.text,
                                style: TextStyle(
                                  color: m.isUser
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Processing indicator
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(),
            ),

          // Input field
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isProcessing,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _isProcessing ? null : _sendMessage,
                    mini: true,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'needs_salary_slip':
      case 'need_more_info':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
