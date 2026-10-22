import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/auth_controller.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identificador = TextEditingController();
  final _senha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Consumer<AuthController>(
        builder: (context, controleAuth, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone ou Logo no topo (opcional para dar mais estilo)
                const Icon(
                  Icons.travel_explore,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),

                // Campo de E-mail ou Nome com caixa e ícone
                TextField(
                  controller: _identificador,
                  decoration: InputDecoration(
                    labelText: "E-mail ou Nome",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Senha com caixa e ícone
                TextField(
                  controller: _senha,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Mensagem de Erro
                if (controleAuth.erro.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      controleAuth.erro,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 8),

                // Botão de Entrar com visual mais encorpado
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controleAuth.carregando
                        ? null
                        : () async {
                            final logou = await controleAuth.autenticarUsuario(
                              _identificador.text,
                              _senha.text,
                            );
                            if (logou && context.mounted) {
                              Navigator.pushReplacementNamed(context, 'home'); // pushNamed coloca a tela de home em cima da de login, ja com o pushReplacementNamed torna a home a tela principal e subistitui a login pela home
                            }
                          },
                    child: controleAuth.carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Entrar",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}