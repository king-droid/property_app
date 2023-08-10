import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_feeds/blocs/login/login_bloc.dart';
import 'package:property_feeds/blocs/login/login_event.dart';
import 'package:property_feeds/blocs/login/login_state.dart';
import 'package:property_feeds/components/custom_elevated_button.dart';
import 'package:property_feeds/components/otp_text_field.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';
import 'package:property_feeds/provider/user_provider.dart';
import 'package:property_feeds/utils/app_utils.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  OtpScreenState createState() {
    return OtpScreenState();
  }
}

class OtpScreenState extends State<OtpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();
  TextEditingController otp5Controller = TextEditingController();
  TextEditingController otp6Controller = TextEditingController();

  FocusNode otp1FocusNode = FocusNode();
  FocusNode otp2FocusNode = FocusNode();
  FocusNode otp3FocusNode = FocusNode();
  FocusNode otp4FocusNode = FocusNode();
  FocusNode otp5FocusNode = FocusNode();
  FocusNode otp6FocusNode = FocusNode();

  FocusNode passwordFieldFocusNode = FocusNode();
  FocusNode mobileNumberFieldFocusNode = FocusNode();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final globalKey = GlobalKey<ScaffoldState>();
  bool isSendingOtp = false;
  bool isReSendingOtp = false;
  bool isVerifyingOtp = false;
  bool isSocialLoading = false;
  bool _buttonActive = false;
  bool passwordVisible = true;
  bool isOtSent = false;

  bool _isButtonEnabled = false;
  String mode = "";
  String name = "";
  String firstName = "";
  String lastName = "";
  String password = "";
  String mobileNumber = "";
  String email = "";
  String fees = "";
  String countryCode = "+91";
  String gender = "";
  String state = "";
  String dob = "";
  String address = "";
  String profilePic = "";
  String qualification = "";
  String currentHospital = "";

  String verificationId = "";
  String otp = "";
  String authStatus = "";
  bool enableResend = false;

  void updateButtonState() {
    // if text field has a value and button is inactive
    if (mobileNumberController.text.isNotEmpty &&
        mobileNumberController.text.length == 10) {
      setState(() {
        _buttonActive = true;
      });
    } else {
      setState(() {
        _buttonActive = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      //sendOTP();
    });
  }

  proceedNext() {
    //AppUtils.showToast("OTP verified successfully");
    Navigator.pushNamed(context, AppRoutes.completeProfileScreen);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    //mobileNumber = arguments["mobileNumber"] ?? "";

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        iconTheme: const IconThemeData(
          color: AppColors.lineBorderColor,
          //change your color here
        ),
        elevation: 0,
        centerTitle: true,
        actions: const <Widget>[],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: Colors.white10,
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            child:
                isOtSent ? _buildVerifyOtpWidget() : _buildMobileLoginWidget(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLoginWidget() {
    return Column(
      children: [
        _buildMobileHeadingWidget(),
        _buildMobileNumberTextField(),
        Spacer(),
        _buildSendOtpButton(),
      ],
    );
  }

  Widget _buildVerifyOtpWidget() {
    return Column(
      children: [
        _buildOTPHeadingWidget(),
        Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Form(key: _formKey, child: _buildOTPFields()),
        ),
        //const SizedBox(height: 25),
        _buildResendOTPButton(),
        Spacer(),
        BlocConsumer<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state is Initial) {
              return _buildVerifyButton();
            } else if (state is Loading) {
              return Center(
                child: Container(
                  margin:
                      const EdgeInsets.only(left: 35.0, right: 35.0, top: 1.0),
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                ),
              );
            } else if (state is ProfileInComplete) {
              return _buildVerifyButton();
            } else {
              return _buildVerifyButton();
            }
          },
          listener: (context, state) async {
            if (state is LoggedInWithMobile) {
              if (state.result ?? false) {
                await AppUtils.saveUser(state.user);
                await AppUtils.setLoggedIn();
                Provider.of<UserProvider>(context, listen: false)
                    .createUser(state.user);
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
              }
            } else if (state is ProfileInComplete) {
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushNamed(context, AppRoutes.completeProfileScreen,
                  arguments: state.user);
            } else if (state is Error) {
              AppUtils.showToast(state.error ?? "");
            }
          },
        ),
      ],
    );
  }

  Widget _buildMobileHeadingWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Icon(
              Icons.phone_android,
              color: AppColors.primaryColor,
              size: 80.0,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              "Mobile OTP Login",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              "An OTP will be sent below entered mobile number to login",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildOTPHeadingWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Container(
            child: Icon(
              Icons.phone_android,
              color: AppColors.primaryColor,
              size: 80.0,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              "Verification Code",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              "We sent an OTP to mobile number you just entered, Please enter below",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNumberTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Text("Mobile number",
              style: Theme.of(context).textTheme.bodyLarge),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 35.0, right: 35.0, top: 10.0),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: AppColors.textFieldBgColorLight,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0))),
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Icon(
                  Icons.phone_android,
                  color: AppColors.primaryColor,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (value) => updateButtonState(),
                  controller: mobileNumberController,
                  onSubmitted: (String value) {
                    FocusScope.of(context).requestFocus(passwordFieldFocusNode);
                    mobileNumberFieldFocusNode.unfocus();
                  },
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  obscureText: false,
                  focusNode: mobileNumberFieldFocusNode,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    hintText: 'Enter your mobile number',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.black38),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSendOtpButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 35.0, right: 35.0, top: 20.0),
      alignment: Alignment.center,
      child: isSendingOtp
          ? Center(
              child: Container(
                margin:
                    const EdgeInsets.only(left: 35.0, right: 35.0, top: 1.0),
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              ),
            )
          : CustomElevatedButton(
              text: "Send OTP",
              color: AppColors.primaryColor,
              textStyle: const TextStyle(
                  fontSize: 16,
                  color: AppColors.buttonTextColorWhite,
                  fontFamily: "Muli"),
              onPress: !_buttonActive
                  ? null
                  : () {
                      sendOtp();
                      /*FocusScope.of(context).requestFocus(FocusNode());
                      setState(() {
                        _buttonActive ? login(context) : null;
                      });*/
                    },
            ),
    );
  }

  void sendOtp() {
    setState(() {
      isSendingOtp = true;
    });

    Future.delayed(Duration(milliseconds: 2000)).then((value) {
      setState(() {
        isSendingOtp = false;
        enableResend = true;
        isOtSent = true;
      });
    });

    return;

    FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: countryCode + mobileNumberController.text,
      timeout: const Duration(seconds: 30),
      verificationCompleted: (AuthCredential authCredential) {
        setState(() {
          isSendingOtp = false;
        });
        proceedNext();
        //AppUtils.navigateToScreenWithReplace(context, AppRoutes.doctorLogin);
        //AppUtils.showToast("OTP verified successfully");
      },
      verificationFailed: (FirebaseAuthException authException) {
        setState(() {
          isSendingOtp = false;
        });
        AppUtils.showToast("Failed to send OTP ${authException.message ?? ""}");
      },
      codeSent: (String verId, [int? forceCodeResent]) {
        setState(() {
          isSendingOtp = false;
          isOtSent = true;
        });
        verificationId = verId;
        AppUtils.showToast("OTP sent successfully");
        otp1Controller.text = "";
        otp2Controller.text = "";
        otp3Controller.text = "";
        otp4Controller.text = "";
        otp5Controller.text = "";
        otp6Controller.text = "";
        setState(() {
          _isButtonEnabled = false;
        });
        Future.delayed(const Duration(seconds: 30), () {
          setState(() {
            enableResend = true;
          });
        });
        //otpDialogBox(context).then((value) {});
      },
      codeAutoRetrievalTimeout: (String verId) {
        setState(() {
          isSendingOtp = false;
        });
        verificationId = verId;
        // Auto retrieval time out
      },
    );
  }

  void login(BuildContext context) {
    /*setState(() {
      _isLoading = true;
    });*/
    Navigator.of(context).pushNamed(AppRoutes.otpScreen,
        arguments: {"mobileNumber": mobileNumberController.text});
  }

  _buildOTPFields() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(left: 2, right: 2),
              child: OtpTextField(
                focusNode: otp1FocusNode,
                textInputAction: TextInputAction.next,
                isRequired: true,
                controller: otp1Controller,
                textInputType: TextInputType.number,
                onChanged: (v) {
                  validateForm(context);
                  if (v.toString().length == 1) {
                    FocusScope.of(context).requestFocus(otp2FocusNode);
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(left: 2, right: 2),
              child: OtpTextField(
                focusNode: otp2FocusNode,
                textInputAction: TextInputAction.next,
                isRequired: true,
                controller: otp2Controller,
                textInputType: TextInputType.number,
                onChanged: (v) {
                  validateForm(context);
                  if (v.toString().length == 1) {
                    FocusScope.of(context).requestFocus(otp3FocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(otp1FocusNode);
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(left: 2, right: 2),
              child: OtpTextField(
                focusNode: otp3FocusNode,
                textInputAction: TextInputAction.next,
                isRequired: true,
                controller: otp3Controller,
                textInputType: TextInputType.number,
                onChanged: (v) {
                  validateForm(context);
                  if (v.toString().length == 1) {
                    FocusScope.of(context).requestFocus(otp4FocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(otp2FocusNode);
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(left: 2, right: 2),
              child: OtpTextField(
                focusNode: otp4FocusNode,
                textInputAction: TextInputAction.next,
                isRequired: true,
                controller: otp4Controller,
                textInputType: TextInputType.number,
                onChanged: (v) {
                  validateForm(context);
                  if (v.toString().length == 1) {
                    FocusScope.of(context).requestFocus(otp5FocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(otp3FocusNode);
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(left: 2, right: 2),
              child: OtpTextField(
                focusNode: otp5FocusNode,
                textInputAction: TextInputAction.next,
                isRequired: true,
                controller: otp5Controller,
                textInputType: TextInputType.number,
                onChanged: (v) {
                  validateForm(context);
                  if (v.toString().length == 1) {
                    FocusScope.of(context).requestFocus(otp6FocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(otp4FocusNode);
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(left: 2, right: 2),
              child: OtpTextField(
                focusNode: otp6FocusNode,
                textInputAction: TextInputAction.done,
                isRequired: true,
                controller: otp6Controller,
                textInputType: TextInputType.number,
                onChanged: (v) {
                  validateForm(context);
                  if (v.toString().length == 1) {
                    FocusScope.of(context).unfocus();
                  } else {
                    FocusScope.of(context).requestFocus(otp5FocusNode);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildResendOTPButton() {
    return Container(
        margin: EdgeInsets.only(top: 20),
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: enableResend
              ? () {
                  sendOtp();
                  /* setState(() {
                    enableResend = false;
                  });*/
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isSendingOtp
                  ? Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  : Container(),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.all(8),
                //color: Colors.blue,
                child: Text("Resend OTP",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          decoration: TextDecoration.underline,
                        )),
              ),
            ],
          ),
        ));
  }

  _buildVerifyButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: isVerifyingOtp
          ? Container(
              margin: const EdgeInsets.only(
                  top: 18, bottom: 10, left: 20, right: 20),
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              ),
            )
          : Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(
                  top: 18, bottom: 10, left: 20, right: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _isButtonEnabled
                        ? AppColors.primaryColor
                        : const Color(0xffb8b8b8),
                    //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: const TextStyle(
                        fontSize: 16,
                        color: AppColors.buttonTextColorWhite,
                        fontFamily: "Muli"),
                    shape: const StadiumBorder()),
                child: const Text("Verify OTP",
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.buttonTextColorWhite,
                        fontFamily: "Muli")),
                onPressed: () async {
                  if (_isButtonEnabled) {
                    setState(() {
                      isVerifyingOtp = true;
                    });

                    /*Future.delayed(Duration(milliseconds: 2000)).then((value) {
                      setState(() {
                        isVerifyingOtp = false;
                        enableResend = true;
                        isOtSent = true;
                      });
                      proceedNext();
                    });*/
                    BlocProvider.of<LoginBloc>(context)
                        .add(LoginWithMobile(mobileNumberController.text));

                    return;
                    otp = otp1Controller.text +
                        otp2Controller.text +
                        otp3Controller.text +
                        otp4Controller.text +
                        otp5Controller.text +
                        otp6Controller.text;

                    try {
                      var result = await FirebaseAuth.instance
                          .signInWithCredential(PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: otp,
                      ));
                      setState(() {
                        isVerifyingOtp = true;
                      });
                      //AppUtils.showToast("OTP verified successfully");
                      proceedNext();
                    } on FirebaseAuthException catch (error, e) {
                      setState(() {
                        isVerifyingOtp = false;
                      });
                      if (error.code == "session-expired") {
                        AppUtils.showToast("OTP expired. Please resend");
                        otp1Controller.text = "";
                        otp2Controller.text = "";
                        otp3Controller.text = "";
                        otp4Controller.text = "";
                        otp5Controller.text = "";
                        otp6Controller.text = "";
                        setState(() {
                          _isButtonEnabled = false;
                        });
                      } else if (error.code == "invalid-verification-code") {
                        AppUtils.showToast("Invalid OTP");
                      } else {
                        AppUtils.showToast(error.message ?? "");
                      }
                    }
                  }
                },
              ),
            ),
    );
  }

  void validateForm(BuildContext context) {
    bool status = false;
    if (otp1Controller.text.isEmpty ||
        otp2Controller.text.isEmpty ||
        otp3Controller.text.isEmpty ||
        otp4Controller.text.isEmpty ||
        otp5Controller.text.isEmpty ||
        otp6Controller.text.isEmpty) {
      status = false;
    } else {
      status = true;
    }

    setState(() {
      _isButtonEnabled = status;
    });
  }

  bool _validateForm() {
    if (_formKey.currentState!.validate()) {}
    /*if (_phoneController.text.isEmpty) {
      return false;
    } else if (_nameController.text.isEmpty) {
      return false;
    } else if (_consultationFeeController.text.isEmpty) {
      return false;
    } else if (!_isTermsAgreed) {
      return false;
    } else {
      return true;
    }*/
    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius = 10.0;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
