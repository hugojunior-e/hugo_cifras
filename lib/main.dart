import 'dart:convert';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:web_browser/web_browser.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hugo Jr - Cifras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SearchScreen(),
    );
  }
}


//-----------------------------------------------------------------------------------------------------


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}


//-----------------------------------------------------------------------------------------------------


class _SearchScreenState extends State<SearchScreen> {
  DatabaseHelper ddb = DatabaseHelper();
  List<_LMusic> items = [];


  void search(String query) {
    setState(
      () {
        items.clear();
        List<String> queryL = query.toLowerCase().split(" ");

        for (int i = 0; i < ddb.lista.length; i++) {
          bool b = true;
          for (int j = 0; j < queryL.length; j++) {
            b = b && ddb.lista[i]['titulo'].contains(queryL[j]);
          }

          if (b) {
            _LMusic l = _LMusic();

            l.cifra = ddb.lista[i]['cifra'];
            l.musica = ddb.lista[i]['titulo'];
            l.tom = ddb.lista[i]['tom'];

            items.add(l);
          }
        }
      },
    );
  }

  void itemBuilderOnTap(index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondRoute(items[index])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            onChanged: (value) {
              search(value);
            },
            decoration: const InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(
                Icons.search,
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.list),
        ),
        body: items.isEmpty
            ? const Center(
                child: Text(
                  'No Results Found',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemBuilder: (context, index) {
                  return ListTile(
                      leading: const Icon(Icons.music_note,
                          color: Color.fromARGB(255, 199, 39, 39), size: 30.0),
                      title: Text(
                        items[index].musica.split('/')[2].replaceAll("-", " "),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: <Widget>[
                          Text(items[index].musica.split('/')[1])
                        ],
                      ),
                      onTap: () => itemBuilderOnTap(index),
                      trailing: const Icon(Icons.keyboard_arrow_right,
                          color: Color.fromARGB(255, 199, 39, 39), size: 30.0));
                },
              ));
  }
}


//-----------------------------------------------------------------------------------------------------

class _LMusic {
  String musica = "";
  String tom = "";
  String cifra = "";
}

//-----------------------------------------------------------------------------------------------------

// ignore: must_be_immutable
class SecondRoute extends StatelessWidget {
  var musica = _LMusic();
  var html = "";

  SecondRoute(l, {super.key}) {
    musica = l;
    html = """ 
        <style>
           b { color: red; font-weight: bold; font-size: 40px;} 
           input { font-weight: bold; font-size: 90px;
                    -webkit-border-radius: 200px;
                    -moz-border-radius: 200px;
                    border-radius: 10px;
                    border: 1px solid #2d9fd9;
                    width: 250px;
                    height: 100px;
                    padding-left: 10px;
            }
            h1{
                font-size: 40px;
            }
            pre {
                line-height: 1.6;
                font-size: 40px;
            }
        </style>
        <script>
              function mudarTom(nota, tipoMud) {
                notas = [ 'C', 'C#/Db', 'D', 'D#/Eb', 'E/Fb', 'F', 'F#/Gb', 'G','G#/Ab', 'A', 'A#/Bb', 'B/Cb'  ];

                for (i = 0; i < notas.length; i++) {

                  a = nota == notas[i];
                  b = notas[i].search(nota + "/") >= 0;
                  c = notas[i].search("/" + nota + "\$") > 0;

                  if ( a || b || c  )
                  {
                    idx = (a || b) ? 0 : 1;
                    if (tipoMud == '+')
                    {
                        if (i == notas.length-1 )
                        {
                          dat = notas[0].split("/");
                        }
                        else
                        {
                          dat = notas[i+1].split("/");
                        }
                    }
                    else
                    {
                        if (i == 0 )
                        {
                            dat = notas[notas.length-1].split("/");
                        }
                        else
                        {
                            dat = notas[i-1].split("/");
                        }
                    }

                    return ( dat[dat.length == 1 ? 0 : idx]   )  ;

                  }
                }
              }



              function rep(tipo) {
                  document.querySelectorAll("b").forEach( e => {

                      nota = e.innerHTML.trim();
                      //console.log(nota);
                      l_notas = nota.split("/");
                      //console.log(l_notas);

                      l_notas.forEach( (i_nota) => {
                          //console.log(i_nota);

                          nova_nota = mudarTom(i_nota.replace('°','').replace("m","").replace(/[0-9]/g, ''),   tipo );

                          //console.log(nova_nota);

                          if ( i_nota.search("m") >= 0 )
                            nota = nota.replace(i_nota.replace('°','').replace(/[0-9]/g, ''), nova_nota + "m");
                          else
                            nota = nota.replace(i_nota.replace('°','').replace(/[0-9]/g, '') , nova_nota );
                          //console.log(nota);
                       });
                      e.innerHTML = nota;
                  });
              }      
        </script>

          <table  cellspacing=10>
          <tr>
          <td> <br><h1>Tom: <b>${musica.tom}</b></h1> </td>
          <td> <input type=button value="  -  " onclick="rep('-')"> </td>
          <td> <input type=button value="  +  " onclick="rep('+')"> </td>
          </tr>
          </table>
          <hr>
    """;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Browser(
          initialUriString: Uri.dataFromString(html + musica.cifra,
                  mimeType: 'text/html', encoding: utf8)
              .toString(),
        ),
      ),
    );
  }
}
