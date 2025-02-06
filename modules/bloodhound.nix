{ pkgs, ... }:
{
  devShells.bloodhound = pkgs.mkShell {
    buildInputs = with pkgs; [
      neo4j
      bloodhound
      procps
    ];
    
    shellHook = ''
      export NEO4J_HOME=$PWD/neo4j_data
      
      # Kill any existing neo4j processes
      pkill -f "neo4j" || true
      sleep 2
      
      # Clean up old data
      rm -rf $NEO4J_HOME
      rm -f ~/.neo4j/.cypher_shell_history
      
      # Setup neo4j directories with full transaction structure
      mkdir -p $NEO4J_HOME/{data,logs,conf}
      mkdir -p $NEO4J_HOME/data/transactions/{neo4j,system}
      mkdir -p $NEO4J_HOME/data/databases/{neo4j,system}
      cp ${pkgs.neo4j}/share/neo4j/conf/* $NEO4J_HOME/conf/ || true
      chmod -R 700 $NEO4J_HOME
      
      # Configure neo4j
      cat > $NEO4J_HOME/conf/neo4j.conf << EOF
      server.directories.data=$NEO4J_HOME/data
      server.directories.logs=$NEO4J_HOME/logs
      dbms.security.auth_enabled=true
      dbms.memory.heap.initial_size=512m
      dbms.memory.heap.max_size=1G
      dbms.memory.pagecache.size=512m
      dbms.transaction.timeout=5m
      EOF
      
      # Initialize neo4j with default password
      NEO4J_CONF=$NEO4J_HOME/conf neo4j-admin dbms set-initial-password bloodhound
      
      # Start neo4j in background
      echo "Starting neo4j..."
      NEO4J_CONF=$NEO4J_HOME/conf neo4j console &
      NEO4J_PID=$!
      
      # Wait for neo4j to be fully started
      echo "Waiting for neo4j to start..."
      while ! curl -s http://localhost:7474 >/dev/null; do
        sleep 1
      done
      
      sleep 5
      
      # Start BloodHound
      echo "Starting BloodHound..."
      BloodHound &
      BLOODHOUND_PID=$!
      
      # Print credentials
      echo ""
      echo "Neo4j credentials:"
      echo "URL: bolt://localhost:7687"
      echo "Username: neo4j"
      echo "Password: bloodhound"
      echo ""
      
      cleanup() {
        echo "Shutting down neo4j gracefully..."
        kill -SIGTERM $NEO4J_PID 2>/dev/null || true
        wait $NEO4J_PID 2>/dev/null || true
        kill $BLOODHOUND_PID 2>/dev/null || true
        rm -rf $NEO4J_HOME
      }
      
      # Use trap with the cleanup function
      trap cleanup EXIT INT TERM
      
      # Keep the shell running
      wait $NEO4J_PID
    '';
  };
}
