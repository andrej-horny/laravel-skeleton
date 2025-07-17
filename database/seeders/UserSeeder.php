<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $admin = User::create([
            'firstname' => 'Admin',
            'lastname' => 'DPB',
            'login' => 'admin',
            'password' => \Hash::make('0000'),
            'is_active' => 1,
            'first_login' => 1,
        ]);

        $admin->assignRole('super-admin');
    }
}