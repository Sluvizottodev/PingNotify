import 'package:flutter/material.dart';
import '../../Service/AuthServiceFire.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';
import '../../widgets/TituloBarComp.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final AuthService _authService = AuthService();
  String _errorMessage = '';

  void _login() async {
    String email = _emailController.text;
    String senha = _senhaController.text;
    String? result = await _authService.login(email: email, senha: senha);
    if (result == null) {
      Navigator.pushReplacementNamed(context, '/principal');
    } else {
      setState(() {
        _errorMessage = result;
      });
    }
  }

  void _mostrarDialogoRedefinirSenha() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController emailController = TextEditingController();
        String mensagem = '';

        return AlertDialog(
          title: Text('Redefinir Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: TSizes.md),
              if (mensagem.isNotEmpty)
                Text(
                  mensagem,
                  style: TextStyle(
                      color: mensagem.contains('sucesso')
                          ? Colors.green
                          : Colors.red),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enviar'),
              onPressed: () async {
                String email = emailController.text;
                if (email.isEmpty) {
                  setState(() {
                    mensagem =
                    'Por favor, preencha o e-mail para redefinir a senha.';
                  });
                  return;
                }
                String? result =
                await _authService.redefinicaoSenha(email: email);
                setState(() {
                  mensagem = result == null
                      ? 'E-mail de redefinição de senha enviado com sucesso.'
                      : result;
                });
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TituloPadrao(titulo: 'Login', distanciaDoTopo: TSizes.xl),
            SizedBox(height: TSizes.md),
            SizedBox(height: TSizes.xl),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: TSizes.md),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: TSizes.md),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: TSizes.sm),
            ElevatedButton(
              onPressed: _login,
              child: Text('Logar',
                  style: TextStyle(
                      color: Colors.white, fontSize: TSizes.fontSizeXl)),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.secondaryColor,
                padding: EdgeInsets.symmetric(vertical: TSizes.sm),
              ),
            ),
            SizedBox(height: TSizes.sm),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cadastro');
              },
              child: Text('Cadastrar'),
              style: TextButton.styleFrom(
                foregroundColor: TColors.secondaryColor,
              ),
            ),
            TextButton(
              onPressed: _mostrarDialogoRedefinirSenha,
              child: Text('Redefinir senha'),
              style: TextButton.styleFrom(
                foregroundColor: TColors.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
