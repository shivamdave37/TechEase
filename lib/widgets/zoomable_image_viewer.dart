import 'package:material_ui/material_ui.dart';

class ZoomableImageViewer extends StatefulWidget {
  final String imagePath;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ZoomableImageViewer({
    Key? key,
    required this.imagePath,
    this.height = 240,
    this.fit = BoxFit.contain,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<ZoomableImageViewer> createState() => _ZoomableImageViewerState();
}

class _ZoomableImageViewerState extends State<ZoomableImageViewer> {
  final TransformationController _controller = TransformationController();
  double _currentScale = 1.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.5).clamp(1.0, 4.0);
      _controller.value = Matrix4.diagonal3Values(_currentScale, _currentScale, 1.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.5).clamp(1.0, 4.0);
      _controller.value = Matrix4.diagonal3Values(_currentScale, _currentScale, 1.0);
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _controller.value = Matrix4.identity();
    });
  }

  void _openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Zoom View (Pinch 2 Fingers)', style: TextStyle(fontSize: 18)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 28),
                tooltip: 'Reset Zoom',
                onPressed: _resetZoom,
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              panEnabled: true,
              scaleEnabled: true,
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 80, color: Colors.white54),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(10);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: radius,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Pinch-to-zoom interactive viewer
          ClipRRect(
            borderRadius: radius,
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1.0,
                maxScale: 4.0,
                panEnabled: true,
                scaleEnabled: true,
                onInteractionUpdate: (details) {
                  setState(() {
                    _currentScale = _controller.value.getMaxScaleOnAxis();
                  });
                },
                child: GestureDetector(
                  onDoubleTap: () {
                    if (_currentScale > 1.0) {
                      _resetZoom();
                    } else {
                      _zoomIn();
                    }
                  },
                  child: Image.asset(
                    widget.imagePath,
                    fit: widget.fit,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image, size: 70, color: Colors.black38),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Zoom control toolbar overlay (both gestures & buttons for maximum elderly accessibility)
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pinch, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Zoom',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _zoomOut,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade800, shape: BoxShape.circle),
                    child: const Icon(Icons.remove, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _zoomIn,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade800, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
                if (_currentScale > 1.05) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _resetZoom,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(10)),
                      child: const Text('Reset', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _openFullScreen(context),
                  child: const Icon(Icons.fullscreen, color: Colors.white70, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
