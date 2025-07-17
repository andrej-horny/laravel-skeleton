<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Spatie\Permission\Models\Role;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('roles')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        $roles = [
            ['name' => 'super-admin', 'guard_name' => 'web', 'title' => 'Super admin', 'description' => ''],
            ['name' => 'admin', 'guard_name' => 'web', 'title' => 'Admin', 'description' => '']
        ];

        Role::insert($roles);
    }

}
