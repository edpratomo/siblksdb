ALTER TABLE regencies_cities ADD CONSTRAINT regencies_cities_province_code_fkey FOREIGN KEY (province_code) REFERENCES provinces(code);
ALTER TABLE districts ADD CONSTRAINT districts_regency_city_code_fkey FOREIGN KEY (regency_city_code) REFERENCES regencies_cities(code);
