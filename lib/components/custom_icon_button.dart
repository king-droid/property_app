import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double? cornerRadius;
  final Widget? icon;
  final Color? color;
  final String? text;
  final Function()? onPress;
  final TextStyle? textStyle;
  final double? elevation;

  const CustomIconButton({
    Key? key,
    this.width,
    this.height,
    this.cornerRadius,
    this.icon,
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
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          elevation: elevation ?? 2,
          //shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius ?? 5),
            side:
                BorderSide(color: Colors.black12.withOpacity(0.09), width: 0.5),
          ),
          textStyle: textStyle ??
              const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            icon != null
                ? Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: icon)
                : Container(),
            Container(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  text ?? "",
                  style: textStyle ??
                      const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                )),
          ],
        ),
      ),
    );
  }
}
