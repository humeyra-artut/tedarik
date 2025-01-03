import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase başlatma hatası: $e");
  }
  runApp(MyApp());
}

class FirebaseService {
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Giriş başarısız: $e");
      return null;
    }
  }

  Future<UserCredential?> registerUser(
      {required String email, required String password}) async {
    try {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Kayıt başarısız: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tedarik Paylaşımı',
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _modelYearController = TextEditingController();
  final TextEditingController _warrantyPeriodController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Tedarik>? get othersTedarikList => null;

  List<Tedarik> _filterTedarikList(
      List<Tedarik> tedarikList, String searchKeyword) {
    return tedarikList.where((tedarik) {
      return tedarik.urunAdi.toLowerCase().contains(searchKeyword.toLowerCase()) ||
          tedarik.fiyat.toString().contains(searchKeyword) ||
          tedarik.modelYili.toLowerCase().contains(searchKeyword.toLowerCase()) ||
          tedarik.garantiSuresi.toLowerCase().contains(searchKeyword.toLowerCase());
    }).toList();
  }

  Future<void> addProduct(
      String userId,
      String productName,
      double price,
      String modelYear,
      String warrantyPeriod,
      ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('products')
          .add({
        'productName': productName,
        'price': price,
        'modelYear': modelYear,
        'warrantyPeriod': warrantyPeriod,
      });

      print('Ürün eklendi.');
    } catch (e) {
      print('Girilen ürünü eklemede sorun oluştu : $e');
    }
  }

  void _applyForSupply(Tedarik tedarik, BuildContext context) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('supplyApplications').add({
        'userId': userId,
        'productId': tedarik.urunAdi,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Başvurunuz başarıyla gönderildi.'),
        ),
      );
    } catch (e) {
      print('Başvuru gönderme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Başvuru gönderme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Tedarik Paylaşımı',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
        toolbarHeight: 50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ürün ekle kısmı
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Ürün Adı'),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Fiyat'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 4),
            TextField(
              controller: _modelYearController,
              decoration: InputDecoration(labelText: 'Model Yılı'),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _warrantyPeriodController,
              decoration: InputDecoration(labelText: 'Garanti Süresi'),
            ),
            SizedBox(height: 4),
            ElevatedButton(
              onPressed: () async {
                String productName = _productNameController.text;
                double price = double.tryParse(_priceController.text) ?? 0.0;
                String modelYear = _modelYearController.text;
                String warrantyPeriod = _warrantyPeriodController.text;
                String userId = FirebaseAuth.instance.currentUser!.uid;

                await addProduct(
                  userId,
                  productName,
                  price,
                  modelYear,
                  warrantyPeriod,
                );

                _productNameController.clear();
                _priceController.clear();
                _modelYearController.clear();
                _warrantyPeriodController.clear();
              },
              child: Text(
                  'Ürün Ekle',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(100, 30)
              ),
            ),

            // Diger Kullanıcıların Tedarik Listesi
            SizedBox(height: 3),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple), // Çerçeve rengi
                      borderRadius: BorderRadius.all(Radius.circular(5.0)), // Çerçeve köşe yuvarlama
                    ),
                    child: Text(
                      'Diger Kullanıcıların Tedarikleri',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Diğer kullanıcıların Tedarikleri Kısmı
                  SizedBox(height: 3),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(labelText: 'Ürün araması'),
                  ),
                  SizedBox(height: 3),

                  SizedBox(height: 3),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collectionGroup('products').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text('Başka kullanıcıların tedarikleri yok'),
                          );
                        }

                        List<Tedarik> othersTedarikList = snapshot.data?.docs.map((doc) {
                              return Tedarik.fromMap(doc.data() as Map<String, dynamic>);
                            }).toList() ?? [];


                        String searchKeyword = _searchController.text;
                        List<Tedarik> filteredTedarikList =
                        _filterTedarikList(othersTedarikList, searchKeyword);

                        return _drawList(filteredTedarikList);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawList(List<Tedarik> tedariList) {
    return ListView.builder(
      itemCount: tedariList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(tedariList[index].urunAdi),
          subtitle: Text(
            'Fiyat: \$${tedariList[index].fiyat.toStringAsFixed(2)}\n'
                'Model Yılı: ${tedariList[index].modelYili}\n'
                'Garanti Süresi: ${tedariList[index].garantiSuresi}',
          ),
          trailing: ElevatedButton(
            onPressed: () {
              _applyForSupply(tedariList[index], context);
            },
            child: Text(
              'Başvur',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
          ),
        );
      },
    );
  }
}
class Tedarik {
  final String urunAdi;
  final double fiyat;
  final String modelYili;
  final String garantiSuresi;

  Tedarik({
    required this.urunAdi,
    required this.fiyat,
    required this.modelYili,
    required this.garantiSuresi,
  });

  factory Tedarik.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      //Boş durumu ele alın, varsayılan bir değer döndürün veya bir hata atın.
    }

    final String urunAdi = map?['productName'] ?? 'Bilgi Yok';
    final double fiyat = (map?['price'] as num?)?.toDouble() ?? 0.0;
    final String modelYili = map?['modelYear']?.toString() ?? 'Bilgi Yok';
    final String garantiSuresi = map?['warrantyPeriod']?.toString() ?? 'Bilgi Yok';

    return Tedarik(
      urunAdi: urunAdi,
      fiyat: fiyat,
      modelYili: modelYili,
      garantiSuresi: garantiSuresi,
    );
  }

}

class TedarikDetailPage extends StatelessWidget {
  final Tedarik tedarik;

  TedarikDetailPage({required this.tedarik});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tedarik.urunAdi),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Fiyat: ${tedarik.fiyat.toStringAsFixed(2)}'),
            Text('Model Yılı: ${tedarik.modelYili}'),
            Text('Garanti Süresi: ${tedarik.garantiSuresi}'),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String _email, _password;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Giriş',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  )
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen bir e-posta adresi girin';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password  ',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.length < 8) {
                    return 'Lütfen en az 8 karakterli bir şifre girin';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState?.save();
                        await login();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: Text(
                      'Giriş',
                      style: TextStyle(
                        color: Colors.white, // Yazı rengi
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState?.save();
                        await register();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // İstenilen renk burada ayarlanır
                    ),
                    child: Text(
                      'Kayıt Ol',
                      style: TextStyle(
                        color: Colors.white, // Yazı rengi
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    final userCredential =
    await _firebaseService.signInWithEmailAndPassword(_email, _password);

    if (userCredential != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hoş Geldin ${userCredential.user!.email}!'),
        ),
      );
      Get.to(MyHomePage());
    }
  }

  Future<void> register() async {
    final userCredential = await _firebaseService.registerUser(
        email: _email, password: _password);

    if (userCredential != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Kayıt Başarılı! Hoş Geldin ${userCredential.user!.email}!'),
        ),
      );
      Get.to(MyHomePage());
    }
  }
}