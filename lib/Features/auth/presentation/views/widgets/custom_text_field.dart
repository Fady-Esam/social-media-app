import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    required this.onChanged,
    this.autovalidateMode = AutovalidateMode.disabled,
  });
  final String hint;
  final IconData prefixIcon;
  final void Function(String value) onChanged;
  final AutovalidateMode autovalidateMode;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '${widget.hint} Field is required';
        } else if (widget.hint == 'Email') {
          if (!RegExp(
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
              .hasMatch(value)) {
            return 'Invalid Email, It must be a valid email address';
          }
        }
        return null;
      },
      autovalidateMode: widget.autovalidateMode,
      onChanged: widget.onChanged,
      obscureText: widget.hint == 'Password' && !isVisible,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: widget.hint == 'Password'
            ? IconButton(
                onPressed: () {
                  isVisible = !isVisible;
                  setState(() {});
                },
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,

          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}
