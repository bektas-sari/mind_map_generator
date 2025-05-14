import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MindMapApp());
}

class MindMapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Map Generator',
      debugShowCheckedModeBanner: false,
      home: MindMapScreen(),
    );
  }
}

class Node {
  Offset position;
  String label;

  Node({required this.position, required this.label});
}

class MindMapScreen extends StatefulWidget {
  @override
  _MindMapScreenState createState() => _MindMapScreenState();
}

class _MindMapScreenState extends State<MindMapScreen> {
  List<Node> nodes = [];
  int nodeCounter = 1;

  void _addNode() {
    setState(() {
      nodes.add(
        Node(
          position: Offset(100 + Random().nextInt(100).toDouble(), 100 + Random().nextInt(100).toDouble()),
          label: 'Node $nodeCounter',
        ),
      );
      nodeCounter++;
    });
  }
  void _editNodeLabel(Node node) {
    final TextEditingController editController =
    TextEditingController(text: node.label);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Node Label'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Enter new label'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  node.label = editController.text.trim().isEmpty
                      ? node.label
                      : editController.text.trim();
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mind Map Generator'),
        backgroundColor: Colors.indigo,
      ),
      body: InteractiveViewer(
        boundaryMargin: EdgeInsets.all(1000),
        minScale: 0.5,
        maxScale: 2.5,
        child: Stack(
          children: [
            CustomPaint(
              painter: ConnectionPainter(nodes),
              child: Container(),
            ),
            ...nodes.map((node) {
              return Positioned(
                left: node.position.dx,
                top: node.position.dy,
                child: Draggable(
                  feedback: _buildNode(node.label, isDragging: true),
                  childWhenDragging:
                  Opacity(opacity: 0.3, child: _buildNode(node.label)),
                  onDraggableCanceled: (velocity, offset) {
                    setState(() {
                      node.position = offset;
                    });
                  },
                  child: GestureDetector(
                    onDoubleTap: () => _editNodeLabel(node),
                    child: _buildNode(node.label),
                  ),

                ),
              );
            }).toList(),
          ],
        ),
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: _addNode,
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildNode(String label, {bool isDragging = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDragging ? Colors.indigo.withOpacity(0.7) : Colors.indigo,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (!isDragging)
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final List<Node> nodes;

  ConnectionPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.indigo.withOpacity(0.6)
      ..strokeWidth = 2;

    for (int i = 0; i < nodes.length - 1; i++) {
      final start = nodes[i].position + Offset(50, 20); // ortalama nokta
      final end = nodes[i + 1].position + Offset(50, 20);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
