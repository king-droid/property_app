import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double? cornerRadius;
  final Color? color;
  final String? text;
  final Function()? onPress;
  final TextStyle? textStyle;
  final double? elevation;

  const CustomElevatedButton({
    Key? key,
    this.width,
    this.height,
    this.cornerRadius,
    this.color,
    this.text,
    this.onPress,
    this.textStyle,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          elevation: elevation ?? 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius ?? 5),
          ),
          textStyle: textStyle ??
              const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
        ),
        child: Text(text ?? ""),
      ),
    );
  }
}
