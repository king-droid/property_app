import 'package:flutter/material.dart';
import 'package:property_feeds/components/custom_elevated_button.dart';
import 'package:property_feeds/configs/app_routes.dart';
import 'package:property_feeds/constants/appColors.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/login";

  const LoginScreen({super.key});

  @override
  LoginScreenState createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  FocusNode passwordFieldFocusNode = FocusNode();
  FocusNode mobileNumberFieldFocusNode = FocusNode();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isSocialLoading = false;
  bool _buttonActive = false;
  bool passwordVisible = true;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      key: globalKey,
      body: SafeArea(
        /*child: ProgressDialog(*/
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: Colors.white10,
            child: IgnorePointer(
              ignoring: isLoading || isSocialLoading,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 25),
                  _buildHeadingWidget(),
                  //const SizedBox(height: 25),
                  _buildMobileNumberTextField(),
                  Spacer(),
                  _buildSendOtpButton(),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeadingWidget() {
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

  Widget _buildTopLogoWidget() {
    return Container(
      //padding: EdgeInsets.only(top: 30, bottom: 20),
      child: Column(
        children: [
          Image.asset("assets/app_icon.png", width: 100, height: 100),
          Container(
            padding: const EdgeInsets.only(top: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Property",
                      style: TextStyle(
                          fontSize: 20,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: "muli"),
                    ),
                    Text(
                      " Feeds",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontFamily: "muli"),
                    ),
                  ],
                ),
              ],
            ),
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
      child: isLoading
          ? Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 7.0,
                  horizontal: 7.0,
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
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
                      FocusScope.of(context).requestFocus(FocusNode());
                      setState(() {
                        _buttonActive ? login(context) : null;
                      });
                    },
            ),
    );
  }

  void login(BuildContext context) {
    /*setState(() {
      _isLoading = true;
    });*/
    Navigator.of(context).pushNamed(AppRoutes.otpScreen,
        arguments: {"mobileNumber": mobileNumberController.text});
  }
}
