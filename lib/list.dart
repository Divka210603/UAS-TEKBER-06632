import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: list(),
  ));
}

class list extends StatefulWidget {
  @override
  State<list> createState() => _listState();
}

class _listState extends State<list> {
  List mhsdata = [];
  bool isLoading = true;
  String errorMsg = "";

  Future<void> baca_data() async {
    String uri = "http://localhost/tekber/mhs.php";
    try {
      final respon = await http.get(Uri.parse(uri));
      if (respon.statusCode == 200) {
        final data = jsonDecode(respon.body);
        setState(() {
          mhsdata = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = "Error: ${respon.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> hapus_data(String nim) async {
    String uri = "http://localhost/tekber/delete_mhs.php";
    try {
      final respon = await http.post(
        Uri.parse(uri),
        body: {'nim': nim},
      );
      if (respon.statusCode == 200) {
        final data = jsonDecode(respon.body);
        if (data['success']) {
          baca_data();
        } else {
          setState(() {
            errorMsg = "Error: Could not delete data";
          });
        }
      } else {
        setState(() {
          errorMsg = "Error: ${respon.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    baca_data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 233, 31, 223),
        title: Text(
          'Listview Data Perpustakaan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMsg.isNotEmpty
              ? Center(child: Text(errorMsg))
              : Column(
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddMahasiswaPage()),
                          ).then((_) => baca_data()); // Refresh data after returning
                        },
                        child: Text('Tambah Data Pengunjung'),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: mhsdata.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              border: Border.all(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            mhsdata[index]['nim'],
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Text(mhsdata[index]['nama_mhs']),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(mhsdata[index]['jurusan']),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditMahasiswaPage(
                                          nim: mhsdata[index]['nim'],
                                          nama: mhsdata[index]['nama_mhs'],
                                          jurusan: mhsdata[index]['jurusan'],
                                        ),
                                      ),
                                    ).then((_) => baca_data()); // Refresh data after returning
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    hapus_data(mhsdata[index]['nim']);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class AddMahasiswaPage extends StatefulWidget {
  @override
  _AddMahasiswaPageState createState() => _AddMahasiswaPageState();
}

class _AddMahasiswaPageState extends State<AddMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nimController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController jurusanController = TextEditingController();

  Future<void> tambahData() async {
    String uri = "http://localhost/tekber/add_mhs.php";
    try {
      final respon = await http.post(
        Uri.parse(uri),
        body: {
          'nim': nimController.text,
          'nama_mhs': namaController.text,
          'jurusan': jurusanController.text,
        },
      );
      if (respon.statusCode == 200) {
        final data = jsonDecode(respon.body);
        if (data['success']) {
          Navigator.pop(context); // Close the add data page
        } else {
          setState(() {
            // Display an error message
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to add data'),
            ));
          });
        }
      } else {
        setState(() {
          // Display an error message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${respon.statusCode}'),
          ));
        });
      }
    } catch (e) {
      setState(() {
        // Display an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      });
    }
  }
 
//halaman tambah data
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Data Pengunjung'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nimController,
                decoration: InputDecoration(labelText: 'NIM Pengunjung'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter NIM Pengunjung';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama Pengunjung'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Nama Pengunjung';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: jurusanController,
                decoration: InputDecoration(labelText: 'Jurusan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Jurusan Pengunjung';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    tambahData();
                  }
                },
                child: Text('Tambah Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditMahasiswaPage extends StatefulWidget {
  final String nim;
  final String nama;
  final String jurusan;

  EditMahasiswaPage({required this.nim, required this.nama, required this.jurusan});

  @override
  _EditMahasiswaPageState createState() => _EditMahasiswaPageState();
}

class _EditMahasiswaPageState extends State<EditMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nimController;
  late TextEditingController namaController;
  late TextEditingController jurusanController;

  @override
  void initState() {
    super.initState();
    nimController = TextEditingController(text: widget.nim);
    namaController = TextEditingController(text: widget.nama);
    jurusanController = TextEditingController(text: widget.jurusan);
  }

  Future<void> updateData() async {
    String uri = "http://localhost/tekber/update_mhs.php";
    try {
      final respon = await http.post(
        Uri.parse(uri),
        body: {
          'nim': nimController.text,
          'nama_mhs': namaController.text,
          'jurusan': jurusanController.text,
        },
      );
      if (respon.statusCode == 200) {
        final data = jsonDecode(respon.body);
        if (data['success']) {
          Navigator.pop(context); // Close the edit data page
        } else {
          setState(() {
            // Display an error message
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to update data'),
            ));
          });
        }
      } else {
        setState(() {
          // Display an error message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${respon.statusCode}'),
          ));
        });
      }
    } catch (e) {
      setState(() {
        // Display an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data Pengunjung'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nimController,
                decoration: InputDecoration(labelText: 'NIM Pengunjung'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter NIM Pengunjung';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama Pengunjung'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Nama Pengunjung';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: jurusanController,
                decoration: InputDecoration(labelText: 'Jurusan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Jurusan Pengunjung';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    updateData();
                  }
                },
                child: Text('Update Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
