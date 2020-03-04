import 'package:flutter/material.dart';
import 'package:helloworld2/widgets/movie_player_widget.dart';

class PlayMoviePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Movie'),
      ),
      body:     Container(
        child: const MoviePlayerWidget('https://archive.org/download/SampleVideo1280x7205mb/SampleVideo_1280x720_5mb.mp4'),
      ),
    );
  }
}
