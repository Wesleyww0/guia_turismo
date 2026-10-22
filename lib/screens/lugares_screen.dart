import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:provider/provider.dart';

// --- Mapeamento de Categorias (Adicionado) ---
// Função auxiliar para converter o ID em nome legível
String obterNomeCategoria(int id) {
  switch (id) {
    case 1: return "Praças";
    case 2: return "Portos";
    case 3: return "Bairros";
    case 4: return "Shows";
    case 5: return "Feiras";
    default: return "Outro";
  }
}
// -------------------------------------------

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  int _categoriaId = 1;

  // Estilo padrão para as bordas dos inputs (igual ao Login)
  final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  );

  void abrirForm() {
    _nomeController.clear();
    _descricaoController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _categoriaId = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o modal cresça com o teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (contextDialog) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(contextDialog).viewInsets.bottom, // Ajusta para o teclado
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Novo Lugar",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: "Nome do Lugar",
                    prefixIcon: const Icon(Icons.text_fields, color: Colors.blueGrey),
                    border: _inputBorder,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descricaoController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Descrição sutil",
                    prefixIcon: const Icon(Icons.description_outlined, color: Colors.blueGrey),
                    border: _inputBorder,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _categoriaId,
                  decoration: InputDecoration(
                    labelText: "Categoria",
                    prefixIcon: const Icon(Icons.category_outlined, color: Colors.blueGrey),
                    border: _inputBorder,
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Praças")),
                    DropdownMenuItem(value: 2, child: Text("Portos")),
                    DropdownMenuItem(value: 3, child: Text("Bairros")),
                    DropdownMenuItem(value: 4, child: Text("Shows")),
                    DropdownMenuItem(value: 5, child: Text("Feiras")),
                  ],
                  onChanged: (valor) => setState(() => _categoriaId = valor!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latitudeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "Latitude",
                          prefixIcon: const Icon(Icons.map_outlined, color: Colors.blueGrey),
                          border: _inputBorder,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _longitudeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "Longitude",
                          prefixIcon: const Icon(Icons.explore_outlined, color: Colors.blueGrey),
                          border: _inputBorder,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(contextDialog),
                      child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _salvarDados(contextDialog),
                      child: const Text("Salvar Local"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _salvarDados(BuildContext contextDialog) async {
    final novoLugar = LugaresModel(
      id: 0,
      nome: _nomeController.text,
      descricao: _descricaoController.text,
      latitude: double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? 0,
      longitude: double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? 0,
      categoriaId: _categoriaId,
    );
    final controleLugares = context.read<LugaresController>();
    final mensagem = await controleLugares.cadastrarLugar(novoLugar);
    if (!contextDialog.mounted) return;
    ScaffoldMessenger.of(contextDialog).showSnackBar(SnackBar(content: Text(mensagem)));
    if (controleLugares.erro.isEmpty) {
      Navigator.pop(contextDialog);
    }
  }

 
  // ----------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LugaresController>(builder: (context, lugaresController, child) {
        if (lugaresController.carregando) {
          return const Center(child: CircularProgressIndicator());
        }
        if (lugaresController.erro != '') {
          return Center(child: Text(lugaresController.erro, style: const TextStyle(color: Colors.red)));
        }
        if (lugaresController.lugares.isEmpty) {
          return const Center(child: Text("Nenhum lugar encontrado", style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: lugaresController.lugares.length,
          itemBuilder: (context, index) {
            final lugar = lugaresController.lugares[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () {},
                title: Text(lugar.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  // --- Nome da Categoria (Atualizado) ---
                  "Categoria: ${obterNomeCategoria(lugar.categoriaId)}",
                  // ----------------------------------------
                  style: const TextStyle(color: Colors.grey),
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey.shade100,
                  child: const Icon(Icons.place, color: Colors.blueGrey),
                ),
                
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirForm(),
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
      ),
    );
  }
}