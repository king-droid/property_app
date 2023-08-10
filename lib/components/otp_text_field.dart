import 'package:property_feeds/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpTextField extends StatefulWidget {
  OtpTextField(
      {required this.focusNode,
      required this.textInputAction,
      this.hint,
      required this.textInputType,
      this.disabled = false,
      this.obscureText = false,
      this.isRequired = false,
      this.onChanged,
      this.maxLength,
      this.minLength = 1,
      this.initialValue,
      this.suffixIcon,
      this.enabled = true,
      this.style,
      this.controller,
      this.minLines,
      this.inputFormatters});

  final TextInputAction textInputAction;
  final String? hint;
  final TextInputType textInputType;
  final FocusNode focusNode;
  final bool obscureText;
  final bool isRequired;
  final bool disabled;
  final Function? onChanged;
  final int? maxLength;
  final int? minLength;
  final String? initialValue;
  final Widget? suffixIcon;
  final bool enabled;
  final TextStyle? style;
  final TextEditingController? controller;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  _OtpTextFieldState createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  String? errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: width,
          child: Row(
            children: <Widget>[
              Expanded(
                child: widget.disabled
                    ? IgnorePointer(
                        child: TextField(
                          keyboardType: widget.textInputType,
                        ),
                      )
                    : TextFormField(
                        focusNode: widget.focusNode,
                        textAlign: TextAlign.center,
                        initialValue: widget.initialValue,
                        textInputAction: widget.textInputAction,
                        controller: widget.controller,
                        enabled: widget.enabled,
                        minLines: widget.minLines,
                        maxLines: widget.minLines,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                        ],
                        validator: (String? value) {
                          if (widget.isRequired) {
                            if (value?.isEmpty ?? false) {
                              setState(() {
                                errorMessage = "";
                              });
                              return errorMessage;
                            } else if (widget.minLength != null) {
                              if (value!.length < widget.minLength!) {
                                setState(() {
                                  errorMessage = "";
                                });
                                return "";
                              }
                            }
                          }
                          setState(() {
                            errorMessage = null;
                          });
                          return null;
                        },
                        toolbarOptions: const ToolbarOptions(
                            copy: true,
                            cut: true,
                            paste: true,
                            selectAll: true),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        maxLength: 1,
                        onChanged: (v) {
                          widget.onChanged?.call(v);
                        },
                        keyboardType: widget.textInputType,
                        enableInteractiveSelection: true,
                        obscureText: widget.obscureText,
                        decoration: InputDecoration(
                          //contentPadding: const EdgeInsets.all(5),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          disabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: widget.hint,
                          errorStyle: const TextStyle(fontSize: 0),
                          counter: const SizedBox(),
                        ),
                      ),
              ),
              if (widget.suffixIcon != null) widget.suffixIcon!
            ],
          ),
        ),
        errorMessage != null
            ? Container(
                margin: const EdgeInsets.only(
                  top: 5,
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                  ),
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
