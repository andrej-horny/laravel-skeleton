<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>DPB Laravel Base</title>
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="flex items-center justify-center min-h-screen bg-gray-50 text-gray-900 dark:bg-black dark:text-white">

    <div class="text-center space-y-6">
        @if (Route::has('login'))
        <nav>
            @auth
            <a href="{{ url('/dashboard') }}" class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700">
                Dashboard
            </a>
            @else
            <a href="{{ route('login') }}" class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700">
                Log in
            </a>
            @if (Route::has('register'))
            <a href="{{ route('register') }}" class="ml-4 px-4 py-2 rounded bg-gray-600 text-white hover:bg-gray-700">
                Register
            </a>
            @endif
            @endauth
        </nav>
        @endif
        <h1 class="text-3xl font-bold">DPB Laravel Base</h1>
        <footer class="text-sm text-gray-500 dark:text-gray-400">
            Laravel v{{ Illuminate\Foundation\Application::VERSION }} (PHP v{{ PHP_VERSION }})
        </footer>
    </div>
</body>
</html>
