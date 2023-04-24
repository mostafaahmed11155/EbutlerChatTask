import 'package:ebutler_chat/components/custom_text_field.dart';
import 'package:ebutler_chat/pages/authentication/sign_up.dart';
import 'package:ebutler_chat/roles_view/customer_view/customer_view.dart';
import 'package:ebutler_chat/roles_view/operator_view/operator_view.dart';
import 'package:ebutler_chat/services/service_provider.dart';
import 'package:ebutler_chat/services/stream_services/stream_user_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();

  final TextEditingController _password = TextEditingController();
  bool _passwordSecure = true;
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
              SizedBox(height: 150,),
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    CustomTextField(title: 'Email',controller: _email),
                    SizedBox(height: 16),
                    CustomTextField(title: 'Password',controller: _password,secureText: _passwordSecure,suffix: IconButton(
                      onPressed: (){
                        setState(() {
                          _passwordSecure = !_passwordSecure;
                        });
                      },
                      icon: _passwordSecure? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                    )),

                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: login,
                child:  Text('Login'),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue.shade900),
                    fixedSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width, 40))
                ),
              ),
              TextButton(onPressed: (){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignUpScreen(),));

              }, child: const Text('Want to Have Account? Sign Up',style: TextStyle(color: Colors.white),)),
              SizedBox(height: 20,),
              Visibility(child: CircularProgressIndicator(color: Colors.white,),visible: _isLoading,),
              SizedBox(height: 50,),
              SizedBox(height: 100,),
            ],
          ),
        ),
      ),
    );
  }

  login()async{
     setState(() {
       _isLoading = true;
     });
      if(_email.text.isEmpty || _password.text.isEmpty ){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all required fields')));
      }else{
        await Provider.of<ServiceProvider>(context,listen: false).login(email: _email.text.trim(), password: _password.text).then((  value)async{
          if(value != null){
            await Provider.of<ServiceProvider>(context,listen: false).getUserData().then((val)async{
              await StreamUserApi.connectUserForLogIn(idUser: FirebaseAuth.instance.currentUser!.uid);
              print(val['role']);
              if(val['role'] == RoleOptions.customer.name){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CustomerView(),));

              }else if(val['role'] == RoleOptions.operator.name){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => OperatorView(),));

              }
            });

          }

          setState(() {
            _isLoading = false;
          });
        }).catchError(( error){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message.toString())));
          setState(() {
            _isLoading = false;
          });
        });

      }
    }

}
