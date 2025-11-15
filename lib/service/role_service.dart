import 'package:covoit_app/service/supabase_client.dart';

class RoleService {
  Future<bool> isCurrentUserGuard() async {
    final user = supabase.auth.currentUser;

    if (user == null) return false;
    if (user.email == null) return false;

    final email = user.email!;

    final res = await supabase
        .from('guard_emails')
        .select('email')
        .eq('email', email);

    return (res as List).isNotEmpty;
  }
}

final roleService = RoleService();
