import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/firestore/models/listin.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listins = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  void iniState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Listin - App de feira", 
          style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.lightBlue
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFromModal();
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: (listins.isEmpty) 
        ? const Center(
            child: Text(
              "Nenhuma lista ainida.\nVamos criar a primeira?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          )
        : RefreshIndicator( 
          onRefresh: () {
            return refresh();
          }, 
          child: ListView(
            children: List.generate(listins.length, (index)  {
              Listin listin = listins[index];
              return Dismissible(
                key: ValueKey<Listin>(listin),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.lightBlue.shade100,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) => remove(listin), 
                child: ListTile(
                  onTap: () {
                    print('clicou');
                  },
                  onLongPress: () {
                    showFromModal(listin: listin);
                  },
                  leading: const Icon(Icons.list_alt_rounded),
                  title: Text(listin.name),
                  subtitle: Text(listin.id),
                )
              );
            }),
          )
        )
    );
  }

  showFromModal({Listin? listin}) {
    String labelTitle = "Adicionar Listin";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";

    TextEditingController nameController = TextEditingController();

    if (listin != null) {
      labelTitle = "Editando ${listin.name}";
      nameController.text = listin.name;
    }
    
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24)
        )
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32),
          child: ListView(
            children: [
              Text(labelTitle, style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(label: Text("Nome do Listin")),
              ),
              const SizedBox( height: 16 ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    }, 
                    child: Text(
                      labelSkipButton, 
                      style: const TextStyle(color: Colors.lightBlue)),
                  ),
                  const SizedBox(
                    width: 16,
                  ), 
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue),
                    onPressed: () {
                      Listin newListin = Listin(
                        id: const Uuid().v1(), 
                        name: nameController.text
                      );

                      if (listin != null) {
                       newListin.id = listin.id; 
                      }

                      firestore
                        .collection('listin')
                        .doc(newListin.id)
                        .set(newListin.toMap());

                      refresh();

                      Navigator.pop(context);
                    }, 
                    child: Text(
                      labelConfirmationButton, 
                      style: const TextStyle(color: Colors.white))
                  )
                ],
              )
            ],
          ),
        );
      }
    );
  }

  refresh() async {
    List<Listin> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = 
      await firestore.collection('listin').get();

    for (var doc in snapshot.docs) {
      temp.add(Listin.fromMap(doc.data()));
    }

    setState(() {
      listins = temp;
    });
  }

  void remove(Listin listin) {
    firestore
      .collection('listin')
      .doc(listin.id)
      .delete();
      
    refresh();
  }
}
