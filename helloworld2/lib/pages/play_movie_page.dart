import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';

class PlayMoviePage extends StatefulWidget {
  const PlayMoviePage():super();
  final String movieUrl = 'https://archive.org/download/SampleVideo1280x7205mb/SampleVideo_1280x720_5mb.mp4';

  @override
  _PlayMoviePageState createState() => _PlayMoviePageState();
}

class _PlayMoviePageState extends State<PlayMoviePage> {
  VideoPlayerController _controller;
  File _movieFile;
  Future<Duration> get _position async => _controller?.position;
  Timer _timer;
  final GlobalKey _globalKey = GlobalKey();
  Image _image;

  Future<void> _doCapture() async {
    final image  = await _convertWidgetToImage();
    setState(() {
      _image = image;
    });
  }

  Future<Image> _convertWidgetToImage() async {
    final boundary =
        _globalKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData.buffer.asUint8List();
    print('pngBytes: ${pngBytes}');
    final image2 = Image.memory(pngBytes);
    print(image2.toString());
    return image2;
  }

  void _refresh() {
    setState(() {});
    _timer = Timer(const Duration(seconds: 1), _refresh);
  }

  void setMovieFile() {
    //_controller = VideoPlayerController.file(_movieFile)
    _controller = VideoPlayerController.network(widget.movieUrl)
      ..initialize().then((_){
      setState(() {});
    });
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
        title: const Text('Play Movie'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                RaisedButton(
                  child: const Text('select movie file'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () async {
//                    final moviePath = await FilePicker.getFilePath(
//                      type: FileType.ANY);
//                    print(moviePath);
//                    setState(() {
//                      _movieFile = File(moviePath);
//                    });
                    setMovieFile();
                  },
                ),
                Text(_movieFile == null ? '' : _movieFile.path.split('/').last),
              ],
            ),
            RepaintBoundary(
              key: _globalKey,
              child: Column(
                children: <Widget>[
                  buildMoviePlayer(context),
                  FutureBuilder(
                      future: _position,
                      builder: (
                          BuildContext context,
                          AsyncSnapshot<Duration> snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data.toString().split('.').first);
                        }
                        else {
                          return const SizedBox();
                        }
                      }
                  ),
                ],
              ),
            ),
            _controller == null ? const SizedBox() : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {_controller.seekTo(const Duration());});
                  },
                  iconSize: 32,
                  icon: Icon(Icons.replay),
                  color: Colors.cyan,
                ),
                IconButton(
                  onPressed: () async {
                    final pos = await _controller.position
                        - const Duration(seconds: 1);
                    setState(() {
                      setState(() {_controller.seekTo(pos);});
                    });
                  },
                  iconSize: 32,
                  icon: Icon(Icons.fast_rewind),
                  color: Colors.cyan,
                ),
                IconButton(
                  onPressed: _controller.value.isPlaying
                      ? () {
                          setState(() {_controller.pause();});
                          _timer?.cancel();
                        }
                      : () {
                          setState(() {_controller.play();});
                          _refresh();
                        },
                  iconSize: 32,
                  icon: _controller.value.isPlaying
                      ? Icon(Icons.pause)
                      : Icon(Icons.play_arrow),
                  color: Colors.cyan,
                ),
                IconButton(
                  onPressed: () async {
                          final pos = await _controller.position
                              + const Duration(seconds: 1);
                          setState(() {
                            setState(() {_controller.seekTo(pos);});
                          });
                        },
                  iconSize: 32,
                  icon: Icon(Icons.fast_forward),
                  color: Colors.cyan,
                ),
              ],
            ),
            RaisedButton(
              child: const Text('Screen Shot'),
              color: Colors.blue,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () async {
                await _doCapture();
              },
            ),
            Container(
              color: Colors.yellow,
              height: 200,
              child: Center(
                child: _image == null ? const SizedBox() : _image,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMoviePlayer(BuildContext context) {
    if (_controller == null) {
      return Container(
      );
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
