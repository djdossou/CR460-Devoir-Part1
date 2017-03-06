//creation du réseau cr460
resource "google_compute_network" "cr460" {
  name                    = "cr460"
  auto_create_subnetworks = "false"
}

//creation du sous-réseau public
resource "google_compute_subnetwork" "public" {
  name          = "public"
  ip_cidr_range = "172.16.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

//creation du sous-réseau workload
resource "google_compute_subnetwork" "workload" {
  name          = "workload"
  ip_cidr_range = "10.0.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

//creation du sous-réseau backend
resource "google_compute_subnetwork" "backend" {
  name          = "backend"
  ip_cidr_range = "10.0.2.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}


//regle de firewall entre le sous-reseau public et le reseau cr460
resource "google_compute_firewall" "web-http-https" {
  name    = "web-http-https"
  network = "${google_compute_subnetwork.public.name}"
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
}

resource "google_compute_firewall" "ssh1" {
  name    = "ssh1"
  network = "${google_compute_subnetwork.public.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
}

//regle de firewall entre les sous-reseaux workload et public

resource "google_compute_firewall" "ssh2" {
  name    = "ssh2"
  network = "${google_compute_subnetwork.workload.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
source_ranges = ["${google_compute_subnetwork.public.ip_cidr_range}"]
}


//regle de firewall pour les sous-reseaux workload et backend

resource "google_compute_firewall" "rule1" {
  name    = "rule1"
  network = "${google_compute_subnetwork.backend.name}"
  allow {
    protocol = "tcp"
    ports    = ["2379", "2380"]
  }
source_ranges = ["${google_compute_subnetwork.workload.ip_cidr_range}"]
  
}

resource "google_compute_firewall" "ssh3" {
  name    = "ssh3"
  network = "${google_compute_subnetwork.backend.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
source_ranges = ["${google_compute_subnetwork.workload.ip_cidr_range}"]
  
}

//regle de firewall entre les sous-reseaux public et backend
resource "google_compute_firewall" "rule2" {
  name    = "rule2"
  network = "${google_compute_subnetwork.backend.name}"
  allow {
    protocol = "tcp"
    ports    = ["2379", "2380"]
  }
source_ranges = ["${google_compute_subnetwork.public.ip_cidr_range}"]
  
}

resource "google_compute_firewall" "ssh4" {
  name    = "ssh4"
  network = "${google_compute_subnetwork.backend.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
source_ranges = ["${google_compute_subnetwork.public.ip_cidr_range}"]
  
}

resource "google_dns_record_set" "www1" {
  name = "www.vault.djdossou.cr460lab.com."
  type = "A"
  ttl  = 300

  managed_zone = "vault.djdossou.cr460lab"

  rrdatas = ["${google_compute_instance.vault.network_interface.0.access_config.0.assigned_nat_ip}"]
}

resource "google_dns_record_set" "www2" {
  name = "www.jump.djdossou.cr460lab.com."
  type = "A"
  ttl  = 300

  managed_zone = "jump.djdossou.cr460lab"

  rrdatas = ["${google_compute_instance.jumphost.network_interface.0.access_config.0.assigned_nat_ip}"]
}