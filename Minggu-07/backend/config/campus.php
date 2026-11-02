<?php

return [
    'access_ttl' => (int) env('ACCESS_TOKEN_TTL', 900),
    'firebase_project' => env('FIREBASE_PROJECT_ID'),
    'firebase_credentials' => env('FIREBASE_CREDENTIALS'),
];
