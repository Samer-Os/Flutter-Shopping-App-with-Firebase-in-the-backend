import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/cart.dart';
import '../Providers/product.dart';
import '../Providers/products.dart';

class EditAddProduct extends StatefulWidget {
  const EditAddProduct({Key? key}) : super(key: key);
  static const routeName = 'EditAddProduct';

  @override
  State<EditAddProduct> createState() => _EditAddProductState();
}

class _EditAddProductState extends State<EditAddProduct> {
  late final imageUrlController;
  late final productData;
  bool isLoading = false;
  bool init = true;

  @override
  void didChangeDependencies() {
    if (init) {
      productData = ModalRoute.of(context)!.settings.arguments != null
          ? ModalRoute.of(context)!.settings.arguments as Map<String, Object>
          : null;
      imageUrlController = productData == null
          ? TextEditingController()
          : TextEditingController(text: productData['imageUrl'] as String);
      init = false;
    }
    super.didChangeDependencies();
  }

  bool isUrlValid = true;
  var form = GlobalKey<FormState>();
  var editedProduct = Product(
    id: '',
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  @override
  void dispose() {
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> saveForm() async {
    final isValid = form.currentState!.validate();
    if (!isValid) {
      return;
    }
    form.currentState!.save();
    try {
      setState(() {
        isLoading = true;
      });
      if (productData == null) {
        await Provider.of<Products>(context, listen: false)
            .addEditProduct(editedProduct, '');
      } else {
        await Provider.of<Products>(context, listen: false)
            .addEditProduct(editedProduct, productData['id'] as String);
        Provider.of<Cart>(context, listen: false).updateCartInfo(
          productData['id'] as String,
          editedProduct.title,
          editedProduct.price,
        );
      }
    } catch (_) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'An error occurred, verify your internet',
          textAlign: TextAlign.center,
        )),
      );
      rethrow;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveForm,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: TextFormField(
                          initialValue: productData == null
                              ? editedProduct.title
                              : productData['title'] as String,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a title';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onSaved: (enteredValue) {
                            editedProduct = Product(
                              id: editedProduct.id,
                              title: enteredValue!,
                              price: editedProduct.price,
                              description: editedProduct.description,
                              imageUrl: editedProduct.imageUrl,
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          initialValue: productData == null
                              ? editedProduct.price == 0
                                  ? ''
                                  : editedProduct.price.toStringAsFixed(2)
                              : productData['price'] as String,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please provide a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Please provide a positive number greater than zero';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          onSaved: (enteredValue) {
                            editedProduct = Product(
                              id: editedProduct.id,
                              title: editedProduct.title,
                              price: double.parse(enteredValue!),
                              description: editedProduct.description,
                              imageUrl: editedProduct.imageUrl,
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                          maxLines: 3,
                          initialValue: productData == null
                              ? editedProduct.description
                              : productData['description'] as String,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a description';
                            }
                            if (value.length < 10) {
                              return 'Should be at least 10 characters long';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.multiline,
                          onSaved: (enteredValue) {
                            editedProduct = Product(
                              id: editedProduct.id,
                              title: editedProduct.title,
                              price: editedProduct.price,
                              description: enteredValue!,
                              imageUrl: editedProduct.imageUrl,
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  style: BorderStyle.solid,
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              child: (imageUrlController.text.isEmpty ||
                                      !isUrlValid)
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'enter image URL',
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Image URL',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter an URL';
                                  }
                                  if (!value.startsWith('http') &&
                                      !value.startsWith('https')) {
                                    isUrlValid = false;
                                    return 'Please enter a valid URL';
                                  }
                                  if (!value.endsWith('.png') &&
                                      !value.endsWith('.jpg') &&
                                      !value.endsWith('.jpeg')) {
                                    isUrlValid = false;
                                    return 'Please enter a valid URL';
                                  }
                                  isUrlValid = true;
                                  return null;
                                },
                                controller: imageUrlController,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.url,
                                onEditingComplete: () {
                                  setState(() {});
                                },
                                onSaved: (enteredValue) {
                                  editedProduct = Product(
                                    id: editedProduct.id,
                                    title: editedProduct.title,
                                    price: editedProduct.price,
                                    description: editedProduct.description,
                                    imageUrl: enteredValue!,
                                  );
                                },
                                onFieldSubmitted: (_) {
                                  saveForm();
                                },
                              ),
                            ),
                          ],
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
