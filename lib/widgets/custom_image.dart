import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(mediaUrl) {
  return CachedNetworkImage(
    errorWidget: (context,url,err)=>Icon(Icons.error),
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (contrxt, url) => Padding(
      padding: EdgeInsets.all(20),
      child: CircularProgressIndicator(),
    ),
  );
}
