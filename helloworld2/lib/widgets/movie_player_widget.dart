import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MoviePlayerWidget extends StatefulWidget {
  const MoviePlayerWidget(this.movieUrl):super();
  final String movieUrl;

  @override
  _MoviePlayerWidgetState createState() => _MoviePlayerWidgetState();

}

class _MoviePlayerWidgetState extends State<MoviePlayerWidget> {

  VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.network(
      widget.movieUrl
    )..initialize().then((_){
      setState(() {});
      _controller.play();
    });
    _controller.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Container();
    }
    if (!_controller.value.initialized) {
      return Container(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );
    }
    return Container(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
