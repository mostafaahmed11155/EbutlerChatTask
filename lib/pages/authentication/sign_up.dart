import 'dart:io';

import 'package:ebutler_chat/components/custom_text_field.dart';
import 'package:ebutler_chat/pages/authentication/login.dart';
import 'package:ebutler_chat/roles_view/customer_view/customer_view.dart';
import 'package:ebutler_chat/roles_view/operator_view/operator_view.dart';
import 'package:ebutler_chat/services/service_provider.dart';
import 'package:ebutler_chat/services/stream_services/stream_user_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

enum RoleOptions { customer, operator }
class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  File? image;
  bool _passwordSecure = true;
  bool _passwordConfirmSecure = true;
  RoleOptions selectedOptionRole = RoleOptions.customer;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,

          ),

        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 70,),
              Image.asset('assets/logos/logo.png',),
              SizedBox(height: 50,),
              Column(
                children: [
                  if (image != null) GestureDetector(onTap: _pickImage,child: CircleAvatar(backgroundImage:FileImage(image!),radius: 60,)),

                  if(image == null)
                    GestureDetector(onTap: _pickImage,child: CircleAvatar(backgroundImage: AssetImage('assets/images/profile_place_holder.jpeg',),radius: 60,)),

                  SizedBox(height: 16),
                  CustomTextField(title: 'Name',controller: _name),
                  SizedBox(height: 16),
                  CustomTextField(title: 'Email',controller: _email),
                  SizedBox(height: 16),
                  CustomTextField(title: 'Phone',controller: _phone),
                  SizedBox(height: 16),
                  CustomTextField(title: 'Password',controller: _password,secureText: _passwordSecure,suffix: IconButton(
                    onPressed: (){
                      setState(() {
                        _passwordSecure = !_passwordSecure;
                      });
                    },
                    icon: _passwordSecure? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                  )),
                  SizedBox(height: 16),
                  CustomTextField(title: 'Confirm Password',controller: _passwordConfirm,secureText: _passwordConfirmSecure,suffix: IconButton(
                    onPressed: (){
                      setState(() {
                        _passwordConfirmSecure = !_passwordConfirmSecure;
                      });
                    },
                    icon: _passwordConfirmSecure? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                  )),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width ,

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 40/ 100,
                      child: RadioListTile(
                        tileColor: Colors.white,
                        activeColor: Colors.white,
                        selectedTileColor: Colors.white,
                        title: Text('Customer',style: TextStyle(color: Colors.white)),
                        value: RoleOptions.customer,
                        groupValue: selectedOptionRole,
                        onChanged: (RoleOptions? value) {
                          setState(() {
                            selectedOptionRole = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 40/ 100,

                      child: RadioListTile(
                        title: Text('Operator',style: TextStyle(color: Colors.white)),
                        activeColor: Colors.white,
                        tileColor: Colors.white,
                        value: RoleOptions.operator,
                        groupValue: selectedOptionRole,
                        onChanged: (RoleOptions? value) {
                          setState(() {
                            selectedOptionRole = value!;
                            print(image);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: signUp,
                child: Text('Sign Up'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue.shade900),
                  fixedSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width, 40))
                ),
              ),
              TextButton(onPressed: (){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen(),));

              }, child: Text('Have Account? Login',style: TextStyle(color: Colors.white),)),
              SizedBox(height: 20,),
              Visibility(child: CircularProgressIndicator(color: Colors.white,),visible: _isLoading,),
              SizedBox(height: 50,),
            ],
          ),
        ),
      ),
    );
  }

  void signUp() async{
    String? imageUrl;
    FocusScope.of(context).unfocus();
    if(_email.text.isEmpty || _password.text.isEmpty || _passwordConfirm.text.isEmpty || _name.text.isEmpty || _phone.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all required fields')));
    }else{
      if(_password.text  !=  _passwordConfirm.text){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password doesnot match')));

      }else{
        setState(() {
          _isLoading = true;
        });
        await Provider.of<ServiceProvider>(context,listen: false).signUp(email: _email.text.trim(), password: _password.text).then((  value)async{
          if(value != null){

            if(image != null){
               await Provider.of<ServiceProvider>(context,listen: false).uploadPicture(file: image!).then((res){
                 setState(() {
                   imageUrl = res;
                 });
               });
            }
          }
        }).catchError(( error){
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message.toString())));
        });

        final idUser = FirebaseAuth.instance.currentUser!.uid;
        await StreamUserApi.createUser(idUser: idUser, username: _name.text,  urlImage: imageUrl ?? '',role: (selectedOptionRole == RoleOptions.operator? 'operator' : 'user'));
        await ServiceProvider().storeUserData(name: _name.text, email: _email.text, phone: _phone.text,imageUrl: imageUrl ?? '',role: selectedOptionRole.name);

        //Creation Of Channels ( List Of Conversations )
        await Provider.of<ServiceProvider>(context,listen: false).createChannelForUsers(isCustomer:  selectedOptionRole == RoleOptions.operator ? false : true);
        setState(() {
          _isLoading = false;
        });
        if(selectedOptionRole == RoleOptions.customer){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CustomerView(),));
        }else if(selectedOptionRole == RoleOptions.operator){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => OperatorView(),));

        }


      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
}




