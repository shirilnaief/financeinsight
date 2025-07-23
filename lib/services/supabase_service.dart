import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl = 'your_supabase_url';
  static const String supabaseAnonKey = 'your_supabase_anon_key';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }

  // Auth helpers
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Auth methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // Database helpers
  PostgrestQueryBuilder from(String table) => client.from(table);

  PostgrestFilterBuilder select(String table, [String columns = '*']) {
    return client.from(table).select(columns);
  }

  Future<PostgrestResponse> insert(String table, Map<String, dynamic> data) {
    return client.from(table).insert(data).execute();
  }

  Future<PostgrestResponse> update(String table, Map<String, dynamic> data) {
    return client.from(table).update(data).execute();
  }

  Future<PostgrestResponse> delete(String table) {
    return client.from(table).delete().execute();
  }

  // Real-time subscriptions
  RealtimeChannel subscribe(
    String table, {
    String event = '*',
    String? schema = 'public',
    required void Function(PostgresChangePayload) callback,
  }) {
    return client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: schema ?? 'public',
          table: table,
          callback: callback,
        )
        .subscribe();
  }

  void unsubscribe(RealtimeChannel channel) {
    client.removeChannel(channel);
  }

  // Storage helpers
  SupabaseStorageClient get storage => client.storage;

  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
    Map<String, String>? metadata,
  }) async {
    await storage.from(bucket).uploadBinary(path, Uint8List.fromList(bytes),
        fileOptions: FileOptions(
          upsert: true,
          contentType: metadata?['contentType'],
        ));
    return storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await storage.from(bucket).remove([path]);
  }

  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return storage.from(bucket).getPublicUrl(path);
  }
}