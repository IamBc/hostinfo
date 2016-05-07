CREATE USER api_usr WITH  PASSWORD '123';
GRANT SELECT, INSERT on host_info TO api_usr;
GRANT SELECT on host_info_id_seq TO api_usr;
