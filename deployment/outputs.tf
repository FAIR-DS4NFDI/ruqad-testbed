#
#  Copyright (c) 2023 Contributors to the Eclipse Foundation
#
#  See the NOTICE file(s) distributed with this work for additional
#  information regarding copyright ownership.
#
#  This program and the accompanying materials are made available under the
#  terms of the Apache License, Version 2.0 which is available at
#  https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#  License for the specific language governing permissions and limitations
#  under the License.
#
#  SPDX-License-Identifier: Apache-2.0
#

output "consumer-jdbc-url" {
  #   jdbc:postgresql://localhost:5432/mydatabase?currentSchema=myschema
  value = "jdbc:postgresql://${module.consumer-postgres.database-url}/consumer"
}

output "provider-jdbc-url" {
  value = {
    catalog-server         = "jdbc:postgresql://${module.provider-postgres.database-url}/catalog_server"
    provider-qna           = "jdbc:postgresql://${module.provider-postgres.database-url}/provider_qna"
    provider-manufacturing = "jdbc:postgresql://${module.provider-postgres.database-url}/provider_manufacturing"
  }
}

output "provider-mariadb" {
  value = {
    host = module.provider-mariadb.database-host
    port = module.provider-mariadb.database-port
    ip = module.provider-mariadb.database-ip
  }
}
