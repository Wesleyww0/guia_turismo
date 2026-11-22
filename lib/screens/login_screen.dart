import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:guia_turismo/controller/auth_controller.dart';
import 'package:provider/provider.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

/*
  Dados para entrar no sistema (Login tradicional)
  email: lilia@teste.com | Senha: senha123
*/

class _TelaLoginState extends State<TelaLogin> {
  final _identificador = TextEditingController();
  final _senha = TextEditingController();
  bool _carregandoGoogle = false;

  @override
  void dispose() {
    _identificador.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrarComGoogle() async {
    setState(() => _carregandoGoogle = true);

    try {
      late final UserCredential resultado;

      if (kIsWeb) {
        resultado = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();

        final conta = await googleSignIn.authenticate();
        final credencial = GoogleAuthProvider.credential(
          idToken: conta.authentication.idToken,
        );

        resultado = await FirebaseAuth.instance.signInWithCredential(
          credencial,
        );
      }

      if (!mounted) return;

      // Se autenticou com o Google com sucesso, vai para a tela 'home'
      if (resultado.user != null) {
        Navigator.pushReplacementNamed(context, 'home');
      }
    } catch (e) {
      debugPrint('Erro ao autenticar com Google: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível entrar com o Google.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregandoGoogle = false);
      }
    }
  }

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
                // Ícone / Logo no topo
                const Icon(
                  Icons.travel_explore,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),

                // Campo de E-mail ou Nome
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

                // Campo de Senha
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

                // Mensagem de Erro do AuthController
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

                // Botão de Entrar tradicional
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: (controleAuth.carregando || _carregandoGoogle)
                        ? null
                        : () async {
                            final logou = await controleAuth.autenticarUsuario(
                              _identificador.text,
                              _senha.text,
                            );
                            if (logou && context.mounted) {
                              Navigator.pushReplacementNamed(context, 'home');
                            }
                          },
                    child: controleAuth.carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Entrar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Divisor visual "ou"
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "ou",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),

                const SizedBox(height: 20),

                // Botão de Entrar com o Google
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    onPressed: (controleAuth.carregando || _carregandoGoogle)
                        ? null
                        : _entrarComGoogle,
                    icon: _carregandoGoogle
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login, color: Colors.red),
                    label: Text(
                      _carregandoGoogle
                          ? "Conectando..."
                          : "Entrar com o Google",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
/*
    Dados para entrar no sistema
    email: lilia@teste.com  | Senha: senha123
  */