import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget MessageCardShimmer(int color, Alignment alignment){
  return Align(
    alignment: alignment,
    child: SizedBox(
      height: 60,
      width: 250,
      child: Shimmer.fromColors(
        baseColor: Color(color),
        highlightColor: Color(color).withOpacity(0.5),
        child: Card(
          elevation: 0.0,
          margin: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius
                .circular(8),
          ),
          child: const SizedBox(
              height: 60),
        ),
      ),
    ),
  );
}