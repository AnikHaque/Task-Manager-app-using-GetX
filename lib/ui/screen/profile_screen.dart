import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_manager/data/utils/auth_utility.dart';
import 'package:task_manager/ui/state_managers/profile_controller.dart';
import 'package:task_manager/ui/widgets/custom_button.dart';
import '../../data/models/login_model.dart';
import '../../data/models/network_response.dart';
import '../../data/services/network_caller.dart';
import '../../data/utils/base64_image.dart';
import '../../data/utils/colors.dart';
import '../../data/utils/urls.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/custom_loading.dart';
import '../widgets/screen_background.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  bool _isPasswordChanging = false;

  UserData userData = AuthUtility.userInfo.data!;
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _firstNameTEController = TextEditingController();
  final TextEditingController _lastNameTEController = TextEditingController();
  final TextEditingController _mobileTEController = TextEditingController();

  final TextEditingController _currentPasswordTEController =
      TextEditingController();
  final TextEditingController _newPasswordTEController =
      TextEditingController();
  final TextEditingController _newConfirmPasswordTEController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailTEController.text = userData.email!;
    _firstNameTEController.text = userData.firstName!;
    _lastNameTEController.text = userData.lastName!;
    _mobileTEController.text = userData.mobile!;
  }

  File? image;
  String? base64String;
  Future pickImage(ImageSource imageSource) async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: imageSource, imageQuality: 30);
      if (pickedImage == null) return;

      setState(() {
        image = File(pickedImage.path);
      });

      base64String = await Base64Image.base64EncodedString(image!);
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  final ProfileController _profileController = Get.find();
  Future<Object?> updateProfileShowDialog(BuildContext context) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) {
        return Container();
      },
      transitionBuilder: (_, anim, __, ___) {
        return Transform.scale(
          scale: Curves.easeInOut.transform(anim.value),
          child: CustomAlertDialog(
              onPress: () {
                _profileController
                    .updateProfile(
                        _firstNameTEController.text.trim(),
                        _lastNameTEController.text.trim(),
                        _mobileTEController.text.trim(),
                        base64String ?? AuthUtility.userInfo.data?.photo ?? "")
                    .then((value) {
                  if (value == true) {
                    userData.firstName = _firstNameTEController.text.trim();
                    userData.lastName = _lastNameTEController.text.trim();
                    userData.mobile = _mobileTEController.text.trim();
                    AuthUtility.updateUserInfo(userData);

                    Get.snackbar('Wow', 'Profile Updated.',
                        backgroundColor: mainColor, colorText: Colors.white);
                  } else {
                    Get.snackbar('Failed', 'Try again!',
                        backgroundColor: Colors.red, colorText: Colors.white);
                  }
                });
              },
              title: 'Update Profile',
              content: 'Are you sure to update your profile?',
              actionText: 'ok'),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Future<void> changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();

    _isPasswordChanging = true;
    if (mounted) {
      setState(() {});
    }

    Map<String, dynamic> loginRequestBody = {
      "email": AuthUtility.userInfo.data!.email,
      "password": _currentPasswordTEController.text
    };

    final NetworkResponse loginResponse = await NetworkCaller()
        .postRequest(Urls.loginUrl, loginRequestBody, onProfileScreen: true);

    if (loginResponse.isSuccess) {
      Map<String, dynamic> requestBody = {
        "password": _newPasswordTEController.text,
      };

      final NetworkResponse response =
          await NetworkCaller().postRequest(Urls.profileUpdateUrl, requestBody);

      if (response.isSuccess && mounted) {
        Get.back();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password updated!'),
          backgroundColor: mainColor,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update profile!'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      if (mounted) {
        Fluttertoast.showToast(
            msg: "Wrong current password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    _isPasswordChanging = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('My Profile'),
        ),
        body: ScreenBackground(
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimateList(
                  interval: 60.ms,
                  effects: const [ScaleEffect()],
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 35),
                            child: InkWell(
                              onTap: () => _imageSelectBottomSheet(context),
                              child: CircleAvatar(
                                minRadius: 35,
                                maxRadius: 65,
                                foregroundImage: image != null
                                    ? FileImage(image!)
                                    : Base64Image.getBase64Image(
                                        userData.photo!),
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                            top: 50,
                            right: 100,
                            child: IgnorePointer(
                              child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.add_a_photo)),
                            ))
                      ],
                    ),
                    TextFormField(
                      controller: _emailTEController,
                      decoration: const InputDecoration(
                          hintText: 'Email', labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: false,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter Email!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      controller: _firstNameTEController,
                      decoration: const InputDecoration(
                          hintText: 'First Name', labelText: 'First Name'),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your First Name!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      controller: _lastNameTEController,
                      decoration: const InputDecoration(
                          hintText: 'Last Name', labelText: 'Last Name'),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your Last Name!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      controller: _mobileTEController,
                      decoration: const InputDecoration(
                          hintText: 'Mobile', labelText: 'Mobile'),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your Mobile Number!';
                        }
                        if (value!.length < 11) {
                          return 'Mobile Number is not valid!';
                        }
                        return null;
                      },
                      onEditingComplete: () => updateProfileShowDialog(context),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    GetBuilder<ProfileController>(builder: (controller) {
                      return Visibility(
                        visible: controller.isLoading == false,
                        replacement:
                            const Center(child: CircularProgressIndicator()),
                        child: Column(
                          children: [
                            CustomButton(
                              onTap: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                Get.back();

                                updateProfileShowDialog(context);
                              },
                              buttonText: 'Update',
                            ),
                            const SizedBox(
                              height: 6.0,
                            ),
                            TextButton(
                              onPressed: _changePasswordBottomSheet,
                              child: const Text('Change Password'),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                )),
          ),
        ));
  }

  void _imageSelectBottomSheet(BuildContext context) {
    showModalBottomSheet(
      barrierColor: mainColor.withOpacity(0.15),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Choose an action',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                pickImage(ImageSource.gallery);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                pickImage(ImageSource.camera);
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  void _changePasswordBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 18,
                  right: 18,
                  left: 18,
                  top: 18),
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Change Password',
                              style: TextStyle(color: Colors.green)),
                          IconButton(
                              onPressed: () => Get.back(),
                              icon: Icon(
                                Icons.cancel_outlined,
                                color: Colors.red.shade300,
                              ))
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _currentPasswordTEController,
                      decoration: const InputDecoration(
                          hintText: 'Current Password',
                          labelText: 'Current Password'),
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Fill current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: _newPasswordTEController,
                      decoration: const InputDecoration(
                        hintText: 'New Password',
                        labelText: 'New Password',
                      ),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter New Password!';
                        }
                        if (value!.length < 8) {
                          return 'Password length must be 8 or more!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      controller: _newConfirmPasswordTEController,
                      decoration: const InputDecoration(
                        hintText: 'Confirm New Password',
                        labelText: 'Confirm New Password',
                      ),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please confirm New Password!';
                        }
                        if (value! != _newPasswordTEController.text) {
                          return "Password didn't match!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Visibility(
                      visible: _isPasswordChanging == false,
                      replacement: loader(),
                      child: ElevatedButton(
                        onPressed: changePassword,
                        child: const Text('Proceed'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
