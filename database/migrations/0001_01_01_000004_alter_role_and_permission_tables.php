<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('roles', function (Blueprint $table) {
            $table->string('title')                
                ->nullable()
                ->after('guard_name')
                ->comment('Human readable title, original column `name` will be used in application as unique URI.');
            $table->string('description')                
                ->nullable()
                ->after('title')
                ->comment('Short description of role purpose for easier administration.');

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('roles', function (Blueprint $table) {
            $table->dropColumn('description');
            $table->dropColumn('title');
        });
    }
};
