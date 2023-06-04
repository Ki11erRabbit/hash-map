




static kk_integer_t kk_hash(kk_string_t key, kk_context_t *ctx) {
    kk_ssize_t len = kk_string_len(key, ctx);
    const unsigned char *str = kk_string_buf_borrow(key, &len);
    const int p = 31;
    const int m = 1e9 + 9;
    long long hash_value = 0;
    long long p_pow = 1;
    for (int i = 0; i < len; i++) {
        hash_value = (hash_value + (str[i] + 1ull) * p_pow) % m;
        p_pow = (p_pow * p) % m;
    }
    return kk_integer_from_big64(hash_value, ctx);
}