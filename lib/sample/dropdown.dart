// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   // List of districts
//   final List<String> districts = [
//     'Ariyalur',
//     'Chengalpattu',
//     'Chennai',
//     'Coimbatore',
//     'Cuddalore',
//     'Dharmapuri',
//     'Dindigul',
//     'Erode',
//     'Kallakurichi',
//     'Kanchipuram',
//     'Kanyakumari',
//     'Karur',
//     'Krishnagiri',
//     'Madurai',
//     'Nagapattinam',
//     'Namakkal',
//     'Nilgiris',
//     'Perambalur',
//     'Pudukkottai',
//     'Ramanathapuram',
//     'Ranipet',
//     'Salem',
//     'Sivaganga',
//     'Tenkasi',
//     'Thanjavur',
//     'Theni',
//     'Thoothukudi (Tuticorin)',
//     'Tiruchirappalli',
//     'Tirunelveli',
//     'Tirupathur',
//     'Tiruppur',
//     'Tiruvallur',
//     'Tiruvannamalai',
//     'Tiruvarur',
//     'Vellore',
//     'Viluppuram',
//     'Virudhunagar'
//   ];
//
//   // Variable to hold the selected district
//   String? selectedDistrict;
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('District Dropdown'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               DropdownButton<String>(
//                 hint: Text('Select a district'), // Placeholder text
//                 value: selectedDistrict,         // Currently selected district
//                 icon: Icon(Icons.arrow_drop_down), // Dropdown icon
//                 isExpanded: true,               // Make the dropdown fill the width
//                 items: districts.map((String district) {
//                   return DropdownMenuItem<String>(
//                     value: district,
//                     child: Text(district),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     selectedDistrict = newValue; // Update selected district
//                   });
//                 },
//               ),
//               SizedBox(height: 20), // Add space
//               Text(
//                 selectedDistrict == null
//                     ? 'No district selected'
//                     : 'Selected District: $selectedDistrict',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//
//
// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Searchable Dropdown'),
//         ),
//         body: SearchableDropdownExample(),
//       ),
//     );
//   }
// }
//
// class SearchableDropdownExample extends StatefulWidget {
//   @override
//   _SearchableDropdownExampleState createState() => _SearchableDropdownExampleState();
// }
//
// class _SearchableDropdownExampleState extends State<SearchableDropdownExample> {
//   // List of locations
//   final List<String> locations = [
//     'Arupukottai', 'Kariapattai', 'Rajapalayam', 'Sathur', 'Sivakasi', 'Srivilliputhur', 'Tiruchuli',
//     'Vembakkottai', 'Virudhunagar', 'Watrap', 'Gingee', 'Kandachipuram', 'Marakkanam', 'Melmalaiyanur',
//     'Thiruvennainallur', 'Tindivanam', 'Vanur', 'Vikkiravandi', 'Viluppuram', 'Anaicut', 'Gudiyatham',
//     'Katpadi', 'K V Kuppam', 'Pernambut', 'Vellore', 'Lalgudi', 'Manachanallur', 'Manapparai',
//     'Musiri', 'Srirangam', 'Thiruchirapalli-West', 'Thiruverumpur', 'Thottiyam', 'Thuraiyur',
//     'Tiruchirappalli-East', 'Arani', 'Chengam', 'Chetpet', 'Jamunamarathoor', 'Kalasapakkam', 'Kilpennathur',
//     'Periyakulam', 'Polur', 'Thandarampattu', 'Tiruvannamalai', 'Vandavasi', 'Vembakkam', 'Avinashi',
//     'Dharapuram', 'Kangayam', 'Madathukulam', 'Palladam', 'Tiruppur North', 'Tiruppur South', 'Udumalpet',
//     'Uthukuli', 'Ambur', 'Natrampalli', 'Tirupattur', 'Vaniyambadi', 'Eral', 'Ettayapuram', 'Kayathar',
//     'Kovilpattai', 'Ottapidaram', 'Sathankulam', 'Srivaikundam', 'Thoothukkudi', 'Tiruchendur',
//     'Vilathikulam', 'Koothanallur', 'Kudavasal', 'Mannargudi', 'Nannilam', 'Needamanglam',
//     'Thiruthuraipoondi', 'Thiruvarur', 'Valangaiman', 'Avadi', 'Gummidipoondi', 'Pallipattu',
//     'Ponneri', 'Poonamallee', 'R.K. Pettai', 'Tiruttani', 'Tiruvallur', 'Uthukkotai', 'Ambasamuthiram',
//     'Cheranmahadevi', 'Manur', 'Nanguneri', 'Palayamkottai', 'Radhapuram', 'Thisayanvilai', 'Tirunelveli',
//     'Coonoor', 'Gudalur', 'Kotagiri', 'Kundah', 'Panthalur', 'Udhagamandalam', 'Andipatti',
//     'Bodinayakanur', 'Periyakulam', 'Theni', 'Uthamapalayam', 'Budalur', 'Kumbakonam', 'Orathanadu',
//     'Papanasam', 'Pattukkottai', 'Peravurani', 'Thanjavur', 'Thiruvaiyaru', 'Thiruvidaimarudur',
//     'Alangulam', 'Kadayanallur', 'Sankarankovil', 'Shencottai', 'Sivagiri', 'Tenkasi', 'Thiruvengadam',
//     'V.K.Pudur', 'Devakottai', 'Ilayankudi', 'Kalaiyarkoil', 'Karaikudi', 'Manamadurai', 'Sigampunari',
//     'Sivaganga', 'Thiruppuvanam', 'Tirupathur', 'Attur', 'Edapady', 'Gangavalli', 'Kadayampatti',
//     'Mettur', 'Omalur', 'Pethanaickenpalayam', 'Salem', 'Salem South', 'Salem West', 'Sangagiri',
//     'Valapady', 'Yercaud', 'Arakkonam', 'Arcot', 'Nemili', 'Walajah', 'Kadaladi', 'Kamuthi',
//     'Kilakarai', 'Mudukulathur', 'Paramakudi', 'Rajasingamangalam', 'Ramanathapuram', 'Rameswaram',
//     'Tiruvadanai', 'Alangudi', 'Aranthangi', 'Avadaiyarkoil', 'Gandarvakottai', 'Illuppur', 'Karambakudi',
//     'Kulathur', 'Manamelkudi', 'Ponnamaravathi', 'Pudukkottai', 'Thirumayam', 'Viralimalai', 'Alathur',
//     'Kunnam', 'Perambalur', 'Veppanthattai', 'Kolli Hills', 'Kumarapalayam', 'Mohanur', 'Namakkal',
//     'Paramathi Velur', 'Rasipuram', 'Sendamangalam', 'Thiruchengode', 'Kilvelur', 'Kutthalam',
//     'Mayiladuthurai', 'Nagapattinam', 'Sirkali', 'Tharangambadi', 'Thirukkuvalai', 'Vedaranyam',
//     'Kalligudi', 'Madurai East', 'Madurai North', 'Madurai(South)', 'Madurai West', 'Melur', 'Peraiyur',
//     'Thirupparankundram', 'Tirumangalam', 'Usilampatti', 'Vadipatti', 'Anchetty', 'Bargur', 'Denkanikottai',
//     'Hosur', 'Krishnagiri', 'Pochampalli', 'Shoolagiri', 'Uthangarai', 'Aravakurichi', 'Kadavur',
//     'Karur', 'Krishnarayapuram', 'Kulithalai', 'Manmangalam', 'Pugalur', 'Agasteeswaram', 'Kalkulam',
//     'Killiyoor', 'Thiruvattar', 'Thovalai', 'Vilavancode', 'Kancheepuram', 'KUNDRATHUR', 'Sriperumbudur',
//     'Uthiramerur', 'WALAJABAD', 'Chinnaselam', 'Kallakurichi', 'KALVARAYAN HILLS', 'Sankarapuram',
//     'Tirukkoilur', 'Ulundurpet', 'Anthiyur', 'Bhavani', 'Erode', 'Gobichettipalayam', 'Kodumudi',
//     'Modakkurichi', 'Nambiyur', 'Perundurai', 'Sathyamangalam', 'Thalavadi', 'Attur', 'Dindigul East',
//     'Dindigul West', 'Gujiliamparai', 'Kodaikanal', 'Natham', 'Nilakottai', 'Oddenchatram', 'Palani',
//     'Vedasandur', 'Dharmapuri', 'Harur', 'Karimangalam', 'Nallampalli', 'Palakcode', 'Pappireddipatti',
//     'Pennagaram', 'Bhuvanagiri', 'Chidambaram', 'Cuddalore', 'Kattumannarkoil', 'Kurinjipadi', 'Panruti',
//     'Srimushanam', 'Titakudi', 'Veppur', 'Vridachalam', 'Anaimalai', 'Annur', 'Coimbatore(North)',
//     'Coimbatore(South)', 'Kinathukadavu', 'Madukkarai', 'Mettupalayam', 'Perur', 'Polllachi', 'Sulur',
//     'Valparai', 'Alandur', 'Ambattur', 'Aminjikarai', 'Ayanavaram', 'Egmore', 'Guindy', 'Madhavaram',
//     'Maduravoyal', 'Mambalam', 'Mylapore', 'Perambur', 'Purasawalkam', 'Sholinganallur', 'Thiruvottiyur',
//     'Tondiarpet', 'Velachery', 'CHENGALPATTU', 'CHEYYUR', 'MADHURANTAKAM', 'PALLAVARAM', 'TAMBARAM',
//     'THIRUKKALUKUNDRAM', 'THIRUPPORUR', 'VANDALUR', 'Andimadam', 'Ariyalur', 'Sendurai', 'Udayarpalayam'
//   ];
//
//   String? selectedLocation;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: DropdownSearch<String>(
//         mode: Mode.custom,
//         // showSearchBox: true,
//         // label: "Select a Location",
//       //  hint: "Search and select a location",
//         items: locations,
//         onChanged: (String? newValue) {
//           setState(() {
//             selectedLocation = newValue;
//           });
//         },
//         selectedItem: selectedLocation,
//       ),
//     );
//   }
// }
