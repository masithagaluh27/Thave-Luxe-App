// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:thave_luxe_app/constant/app_color.dart'; // Import your AppColors
// import 'package:thave_luxe_app/tugas_enam_belas/api/store_provider.dart';

// import 'package:thave_luxe_app/tugas_enam_belas/models/category_response.dart'; // Your Category model

// class ManageCategoriesScreen16 extends StatefulWidget {
//   const ManageCategoriesScreen16({super.key});
//   static const String id = '/adminCategory16'; // Unique ID for routing

//   @override
//   State<ManageCategoriesScreen16> createState() =>
//       _ManageCategoriesScreen16State();
// }

// class _ManageCategoriesScreen16State extends State<ManageCategoriesScreen16> {
//   final ApiProvider _apiProvider = ApiProvider();
//   List<Category> _categories = [];
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategories(); // Fetch categories when the screen initializes
//   }

//   // Fetches the list of categories from the API
//   Future<void> _fetchCategories() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//     try {
//       final response = await _apiProvider.getCategories();
//       setState(() {
//         _categories = response.data ?? []; // Update the list of categories
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error =
//             'Failed to load categories: ${e.toString()}'; // Set error message
//         _isLoading = false;
//       });
//     }
//   }

//   // Adds a new category via API
//   Future<void> _addCategory(String name) async {
//     try {
//       await _apiProvider.addCategory(name: name);
//       await _fetchCategories(); // Refresh list after successful addition
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Category added successfully!',
//               style: GoogleFonts.montserrat(color: AppColors.lightText),
//             ),
//             backgroundColor: AppColors.primaryGold,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to add category: ${e.toString()}',
//               style: GoogleFonts.montserrat(color: AppColors.lightText),
//             ),
//             backgroundColor: AppColors.redAccent,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   // Updates an existing category via API
//   Future<void> _updateCategory(int id, String name) async {
//     try {
//       await _apiProvider.updateCategory(id: id, name: name);
//       await _fetchCategories(); // Refresh list after successful update
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Category updated successfully!',
//               style: GoogleFonts.montserrat(color: AppColors.lightText),
//             ),
//             backgroundColor: AppColors.primaryGold,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to update category: ${e.toString()}',
//               style: GoogleFonts.montserrat(color: AppColors.lightText),
//             ),
//             backgroundColor: AppColors.redAccent,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   // Deletes a category after user confirmation
//   Future<void> _deleteCategory(int id) async {
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor:
//               AppColors.cardBackgroundDark, // Dialog background color
//           title: Text(
//             'Confirm Deletion',
//             style: GoogleFonts.playfairDisplay(color: AppColors.lightText),
//           ),
//           content: Text(
//             'Are you sure you want to delete this category?',
//             style: GoogleFonts.montserrat(color: AppColors.subtleText),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.montserrat(color: AppColors.blue),
//               ),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: Text(
//                 'Delete',
//                 style: GoogleFonts.montserrat(color: AppColors.redAccent),
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm == true) {
//       try {
//         await _apiProvider.deleteCategory(id: id);
//         await _fetchCategories(); // Refresh list after successful deletion
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Category deleted successfully!',
//                 style: GoogleFonts.montserrat(color: AppColors.lightText),
//               ),
//               backgroundColor: AppColors.primaryGold,
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Failed to delete category: ${e.toString()}',
//                 style: GoogleFonts.montserrat(color: AppColors.lightText),
//               ),
//               backgroundColor: AppColors.redAccent,
//               duration: const Duration(seconds: 3),
//             ),
//           );
//         }
//       }
//     }
//   }

//   // Shows a dialog for adding a new category or editing an existing one
//   void _showAddEditDialog({Category? category}) {
//     final TextEditingController nameController = TextEditingController(
//       text: category?.name ?? '',
//     );
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor:
//               AppColors.cardBackgroundDark, // Dialog background color
//           title: Text(
//             category == null ? 'Add Category' : 'Edit Category',
//             style: GoogleFonts.playfairDisplay(color: AppColors.lightText),
//           ),
//           content: TextField(
//             controller: nameController,
//             style: GoogleFonts.montserrat(color: AppColors.lightText),
//             decoration: InputDecoration(
//               labelText: 'Category Name',
//               labelStyle: GoogleFonts.montserrat(color: AppColors.subtleText),
//               enabledBorder: const OutlineInputBorder(
//                 borderSide: BorderSide(color: AppColors.subtleGrey),
//               ),
//               focusedBorder: const OutlineInputBorder(
//                 borderSide: BorderSide(color: AppColors.primaryGold),
//               ),
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 'Cancel',
//                 style: GoogleFonts.montserrat(color: AppColors.redAccent),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final name = nameController.text.trim();
//                 if (name.isNotEmpty) {
//                   if (category == null) {
//                     _addCategory(name); // Add new category
//                   } else {
//                     _updateCategory(
//                       category.id!,
//                       name,
//                     ); // Update existing category
//                   }
//                   Navigator.of(context).pop(); // Close the dialog
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         'Category name cannot be empty!',
//                         style: GoogleFonts.montserrat(
//                           color: AppColors.lightText,
//                         ),
//                       ),
//                       backgroundColor: AppColors.redAccent,
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryGold, // Button background
//               ),
//               child: Text(
//                 category == null ? 'Add' : 'Update',
//                 style: GoogleFonts.montserrat(
//                   color: AppColors.textDark,
//                 ), // Button text color
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.darkBackground,
//       appBar: AppBar(
//         title: Text(
//           'Manage Categories',
//           style: GoogleFonts.playfairDisplay(
//             fontWeight: FontWeight.bold,
//             color: AppColors.lightText,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: AppColors.darkBackground,
//         elevation: 0,
//         iconTheme: const IconThemeData(
//           color: AppColors.lightText,
//         ), // Back button color
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.add,
//               color: AppColors.primaryGold,
//             ), // Add icon
//             onPressed:
//                 () => _showAddEditDialog(), // Open dialog to add new category
//             tooltip: 'Add New Category',
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.darkBackground, AppColors.backgroundGradientEnd],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child:
//             _isLoading
//                 ? const Center(
//                   child: CircularProgressIndicator(
//                     color: AppColors.primaryGold,
//                   ),
//                 ) // Loading indicator
//                 : _error != null
//                 ? Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Error: $_error',
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.montserrat(
//                             color: AppColors.redAccent,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton.icon(
//                           onPressed: _fetchCategories,
//                           icon: const Icon(
//                             Icons.refresh,
//                             color: AppColors.textDark,
//                           ),
//                           label: Text(
//                             'Retry',
//                             style: GoogleFonts.montserrat(
//                               color: AppColors.textDark,
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primaryGold,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 12,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//                 : _categories.isEmpty
//                 ? Center(
//                   child: Text(
//                     'No categories found. Add a new category!',
//                     style: GoogleFonts.montserrat(
//                       color: AppColors.subtleText,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//                 : ListView.builder(
//                   padding: const EdgeInsets.all(16.0),
//                   itemCount: _categories.length,
//                   itemBuilder: (context, index) {
//                     final category = _categories[index];
//                     return Card(
//                       elevation: 5,
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       color:
//                           AppColors.cardBackgroundDark, // Card background color
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: ListTile(
//                         title: Text(
//                           category.name ?? 'No Name',
//                           style: GoogleFonts.playfairDisplay(
//                             color: AppColors.primaryGold,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         subtitle: Text(
//                           'ID: ${category.id ?? 'N/A'}',
//                           style: GoogleFonts.montserrat(
//                             color: AppColors.subtleText,
//                             fontSize: 14,
//                           ),
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.edit,
//                                 color: AppColors.blue,
//                               ), // Edit icon
//                               onPressed:
//                                   () => _showAddEditDialog(
//                                     category: category,
//                                   ), // Open dialog to edit
//                               tooltip: 'Edit Category',
//                             ),
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.delete,
//                                 color: AppColors.redAccent,
//                               ), // Delete icon
//                               onPressed:
//                                   () => _deleteCategory(
//                                     category.id!,
//                                   ), // Delete category
//                               tooltip: 'Delete Category',
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//       ),
//     );
//   }
// }
