import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/parking.dart';
import 'supabase_client.dart';

class ParkingService {
  Future<Parking> getFirstParking() async {
    final response = await supabase.from('parking').select().limit(1).single();
    return Parking.fromMap(response as Map<String, dynamic>);
  }

  Future<Parking> getParkingById(String id) async {
    final response =
        await supabase.from('parking').select().eq('id', id).single();
    return Parking.fromMap(response as Map<String, dynamic>);
  }
}

final parkingService = ParkingService();
